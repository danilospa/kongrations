# frozen_string_literal: true

class Environment
  def method_missing(*args)
    method = args.first
    return super unless respond_to_missing?(method.to_s)

    create_getter_and_setter(method[0..-2])
    value = args[1]
    send(method, value)
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.end_with?('=') || super
  end

  private

  def assign_method?(method)
    method.to_s.end_with?('=')
  end

  def create_getter_and_setter(method)
    instance_eval(getter_and_setter(method))
  end

  def getter_and_setter(method)
    "
      def #{method}=(value)
        @method = value
      end

      def #{method}
        @method
      end
    "
  end
end
