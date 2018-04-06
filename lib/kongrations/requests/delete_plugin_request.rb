# frozen_string_literal: true

require 'kongrations/request'

module Kongrations
  class DeletePluginRequest < Request
    attr_accessor :api_name, :plugin_name

    def initialize(api_name, plugin_name)
      @api_name = api_name
      @plugin_name = plugin_name
    end

    def path
      plugin_id = migration_data[api_name]['plugins'][plugin_name]
      "/apis/#{api_name}/plugins/#{plugin_id}"
    end

    def method
      :delete
    end
  end
end
