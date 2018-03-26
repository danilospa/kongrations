# frozen_string_literal: true

change_plugin_for 'api name', 'cors' do |plugin|
  plugin.payload = {
    config: {
      methods: 'POST'
    }
  }
end
