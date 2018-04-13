# frozen_string_literal: true

require 'kongrations/request'

module Kongrations
  class DeleteConsumerRequest < Request
    attr_accessor :username

    def initialize(username)
      @username = username
    end

    def path
      "/consumers/#{username}"
    end

    def method
      :delete
    end
  end
end
