# frozen_string_literal: true

require 'webmock/rspec'
require './lib/kongrations'
require_relative './shared_examples'

def kong_admin_url
  'kong-admin-url.com'
end

def kong_admin_api_key
  '123456789'
end

def stub_kong_request(method, path, request_body = {}, response_body = {})
  stub = stub_request(method, "http://#{kong_admin_url}#{path}")
         .with(headers: { 'apikey' => kong_admin_api_key })
         .and_return(body: response_body.to_json)
  stub.with(body: request_body.to_json) unless request_body.nil?
  stub
end

def stub_create_api_request(payload)
  stub_kong_request(:post, '/apis', payload)
end

def stub_change_api_request(api_name, payload)
  stub_kong_request(:patch, "/apis/#{api_name}", payload)
end

def stub_delete_api_request(api_name)
  stub_kong_request(:delete, "/apis/#{api_name}", nil)
end

def stub_create_plugin_request(api_name, payload, response)
  stub_kong_request(:post, "/apis/#{api_name}/plugins", payload, response)
end

def stub_change_plugin_request(api_name, plugin_id, payload)
  stub_kong_request(:patch, "/apis/#{api_name}/plugins/#{plugin_id}", payload)
end

def delete_mocked_files
  File.delete(Kongrations::MigrationData.file_name) if File.exist?(Kongrations::MigrationData.file_name)
  File.delete(Kongrations::CurrentEnvironment::FILE_NAME) if File.exist?(Kongrations::CurrentEnvironment::FILE_NAME)
end

def mock_data_file(data)
  File.open(Kongrations::MigrationData.file_name, 'w') { |f| f.puts data.to_json }
end

def mock_config_file(data)
  File.open(Kongrations::CurrentEnvironment::FILE_NAME, 'w') { |f| f.puts JSON.parse(data.to_json).to_yaml }
end

RSpec.describe Kongrations do
  let(:migrations_path) { './spec/fixtures/migrations' }

  subject { described_class }

  after { delete_mocked_files }

  describe '.run' do
    before do
      environment = {
        name: 'default',
        'kong-admin-url': kong_admin_url,
        'kong-admin-api-key': kong_admin_api_key
      }
      mock_config_file(environments: [environment])
    end

    context 'when creating api' do
      before do
        payload = {
          name: 'api name',
          upstream_url: 'http://www.uol.com.br',
          uris: '/v2/teste'
        }
        @request_stub = stub_create_api_request(payload)
      end

      include_examples 'behaves like a migration', 'create_api'
    end

    context 'when changing api' do
      before do
        @request_stub = stub_change_api_request('api name', upstream_url: 'http://www.google.com.br')
      end

      include_examples 'behaves like a migration', 'change_api'
    end

    context 'when deleting api' do
      before do
        @request_stub = stub_delete_api_request('api name')
      end

      include_examples 'behaves like a migration', 'delete_api'
    end

    context 'when creating plugin on api' do
      before do
        plugin_request_payload = {
          name: 'cors',
          config: {
            origins: '*',
            methods: 'GET, POST'
          }
        }
        plugin_response_payload = {
          id: 'plugin id'
        }
        @request_stub = stub_create_plugin_request('api name', plugin_request_payload, plugin_response_payload)
      end

      data_to_save = {
        'api name': {
          plugins: {
            cors: 'plugin id'
          }
        }
      }

      include_examples 'behaves like a migration', 'create_plugin', 'default', data_to_save
    end

    context 'when changing plugin on api' do
      before do
        payload = {
          config: {
            methods: 'GET'
          }
        }
        @request_stub = stub_change_plugin_request('api name', 'plugin id', payload)
        mock_data_file('api name': {
                         plugins: {
                           cors: 'plugin id'
                         }
                       })
      end

      include_examples 'behaves like a migration', 'change_plugin'
    end

    context 'when changing plugin after creating it' do
      before do
        plugin_payload = {
          name: 'cors',
          config: {
            methods: 'GET'
          }
        }
        plugin_response = {
          id: 'plugin id'
        }
        @create_plugin_request_stub = stub_create_plugin_request('api name', plugin_payload, plugin_response)
        @change_plugin_request_stub = stub_change_plugin_request('api name', 'plugin id', config: { methods: 'POST' })
        subject.run("#{migrations_path}/create_then_change_plugin")
      end

      it 'performs correct requests' do
        expect(@create_plugin_request_stub).to have_been_requested
        expect(@change_plugin_request_stub).to have_been_requested
      end
    end

    context 'when creating two different plugins' do
      before do
        first_plugin_payload = {
          name: 'cors',
          config: {
            methods: 'GET'
          }
        }
        first_plugin_response = { id: 'first plugin id' }
        @first_stub = stub_create_plugin_request('api name', first_plugin_payload, first_plugin_response)

        second_plugin_payload = {
          name: 'apikey',
          config: 'config'
        }
        second_plugin_response = { id: 'second plugin id' }
        @second_stub = stub_create_plugin_request('api name', second_plugin_payload, second_plugin_response)
        subject.run("#{migrations_path}/create_two_plugins")
      end

      it 'performs correct requests' do
        expect(@first_stub).to have_been_requested
        expect(@second_stub).to have_been_requested
      end

      it 'saves data for two plugins on migration data file' do
        content = JSON.parse(File.read(Kongrations::MigrationData.file_name), symbolize_names: true)
        expect(content[:'api name']).to eq plugins: {
          cors: 'first plugin id',
          apikey: 'second plugin id'
        }
      end
    end

    context 'when running migration after the first one has already be run' do
      before do
        mock_data_file(last_migration: '01_create_api')
        @request_stub = stub_change_api_request('api name', upstream_url: 'upstream url')
        subject.run("#{migrations_path}/change_api_after_already_run_migration")
      end

      it 'performs only change api request' do
        expect(@request_stub).to have_been_requested
      end
    end

    context 'when using environments' do
      before do
        staging_env = {
          name: 'staging',
          'kong-admin-url': kong_admin_url,
          'kong-admin-api-key': kong_admin_api_key
        }
        production_env = {
          name: 'production',
          'kong-admin-url': kong_admin_url,
          'kong-admin-api-key': kong_admin_api_key
        }
        mock_config_file(environments: [staging_env, production_env])
      end

      context 'when using staging' do
        before do
          payload = 'payload for staging'
          @request_stub = stub_create_api_request(payload)
        end

        include_examples 'behaves like a migration', 'create_api_with_two_envs', 'staging'
      end

      context 'when using production' do
        before do
          payload = 'payload for production'
          @request_stub = stub_create_api_request(payload)
        end

        include_examples 'behaves like a migration', 'create_api_with_two_envs', 'production'
      end
    end
  end
end
