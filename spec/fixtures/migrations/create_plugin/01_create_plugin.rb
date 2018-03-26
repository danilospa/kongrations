# frozen_string_literal: true

create_plugin_for 'api name' do |plugin|
  plugin.payload = {
    name: 'cors',
    config: {
      origins: '*',
      methods: 'GET, POST'
    }
  }
end
