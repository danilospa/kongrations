# frozen_string_literal: true

require './lib/kongrations/hash_ext'

using Kongrations::HashExt

RSpec.describe Kongrations::HashExt do
  subject { described_class }

  describe '#deep_merge!' do
    it 'tests' do
      data = { field: { nested_field: 'value' } }
      data.deep_merge!(field: { other_nested_field: 'other value' })
      expect(data).to eq field: { nested_field: 'value', other_nested_field: 'other value' }
    end
  end
end
