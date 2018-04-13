# frozen_string_literal: true

require 'kongrations/request'

module Kongrations
  class CreateConsumerRequest < Request
    def path
      '/consumers'
    end

    def method
      :post
    end
  end
end
