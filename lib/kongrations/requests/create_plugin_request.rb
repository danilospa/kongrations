# frozen_string_literal: true

require_relative '../request'

module Kongrations
  class CreatePluginRequest < Request
    attr_accessor :api_name

    def initialize(api_name)
      @api_name = api_name
    end

    def path
      "/apis/#{api_name}/plugins"
    end

    def method
      :post
    end
  end
end
