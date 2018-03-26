# frozen_string_literal: true

require_relative '../request'

module Kongrations
  class CreateApiRequest < Request
    def path
      '/apis'
    end

    def method
      :post
    end
  end
end
