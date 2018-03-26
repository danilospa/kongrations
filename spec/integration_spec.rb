# frozen_string_literal: true

require 'webmock/rspec'
require './lib/runner'
require_relative './shared_examples'

def stub_kong_request(method, path, request_body = {}, response_body = {})
  stub = stub_request(method, "#{ENV['KONG_BASE_URL']}#{path}")
         .with(headers: { 'apikey' => Request::KONG_ADMIN_API_KEY })
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

def delete_data_file
  File.delete(MigrationData::FILE_NAME) if File.exist?(MigrationData::FILE_NAME)
end

def mock_data_file(data)
  File.open(MigrationData::FILE_NAME, 'w') { |f| f.puts data.to_json }
end

RSpec.describe Runner do
  subject { described_class }

  after { delete_data_file }

  describe '.run' do
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

      include_examples 'behaves like a migration', 'create_plugin', data_to_save
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
        subject.run('./spec/fixtures/migrations/create_then_change_plugin')
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
        subject.run('./spec/fixtures/migrations/create_two_plugins')
      end

      it 'performs correct requests' do
        expect(@first_stub).to have_been_requested
        expect(@second_stub).to have_been_requested
      end

      it 'saves data for two plugins on migration data file' do
        content = JSON.parse(File.read(MigrationData::FILE_NAME), symbolize_names: true)
        expect(content[:'api name']).to eq plugins: {
          cors: 'first plugin id',
          apikey: 'second plugin id'
        }
      end
    end
  end
end
