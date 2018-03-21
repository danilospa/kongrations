# frozen_string_literal: true

require_relative '../request'

class CreateApiRequest < Request
  def path
    '/apis'
  end

  def method
    :post
  end
end
