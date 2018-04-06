# frozen_string_literal: true

require 'kongrations/environment'
Dir["#{__dir__}/requests/*.rb"].each { |file| require file }

module Kongrations
  class Migration
    def initialize(migration_name, current_env)
      @migration_name = migration_name
      @current_env = current_env
      @environments = {}
    end

    def run
      response = change.execute
      response.save_data(@migration_name) if response.success?
      response
    end

    def config_env(env_name)
      environment = Environment.new
      yield(environment)
      @environments[env_name.to_s] = environment
    end

    def env
      @environments[@current_env]
    end

    def create_api
      create_api_request = CreateApiRequest.new
      yield(create_api_request)
      create_api_request
    end

    def change_api(name)
      change_api_request = ChangeApiRequest.new(name)
      yield(change_api_request)
      change_api_request
    end

    def delete_api(name)
      DeleteApiRequest.new(name)
    end

    def create_plugin_for_api(api_name)
      create_plugin_request = CreatePluginRequest.new(api_name)
      yield(create_plugin_request)
      create_plugin_request
    end

    def change_plugin_for_api(api_name, plugin_name)
      change_plugin_request = ChangePluginRequest.new(api_name, plugin_name)
      yield(change_plugin_request)
      change_plugin_request
    end

    def delete_plugin_for_api(api_name, plugin_name)
      DeletePluginRequest.new(api_name, plugin_name)
    end

    def self.build(migration_name, current_env, conten_to_eval)
      klass = new(migration_name, current_env)
      klass.instance_eval("def change; #{conten_to_eval}; end", __FILE__, __LINE__)
      klass
    end
  end
end
