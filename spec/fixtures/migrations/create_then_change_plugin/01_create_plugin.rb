create_plugin_for_api 'api name' do |plugin|
  plugin.payload = {
    name: 'cors',
    config: {
      methods: 'GET'
    }
  }
end
