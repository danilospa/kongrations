# frozen_string_literal: true

require_relative '../request'

class DeleteApiRequest < Request
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def path
    "/apis/#{name}"
  end

  def method
    :delete
  end
end