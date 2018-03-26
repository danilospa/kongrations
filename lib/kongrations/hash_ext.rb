# frozen_string_literal: true

module Kongrations
  module HashExt
    refine Hash do
      def deep_merge!(second)
        merger = proc { |_key, v1, v2| v1.is_a?(Hash) && v2.is_a?(Hash) ? v1.merge(v2, &merger) : v2 }
        merge!(second, &merger)
      end
    end
  end
end
