change_plugin_for_api 'api name', 'cors' do |plugin|
  plugin.payload = {
    config: {
      methods: 'POST'
    }
  }
end
