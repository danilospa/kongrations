# frozen_string_literal: true

require 'kongrations/request'

module Kongrations
  class ChangeConsumerRequest < Request
    attr_accessor :username

    def initialize(username)
      @username = username
    end

    def path
      "/consumers/#{username}"
    end

    def method
      :patch
    end
  end
end
