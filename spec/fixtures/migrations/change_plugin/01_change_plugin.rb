change_plugin_for 'api name', 'cors' do |plugin|
  plugin.payload = {
    config: {
      methods: 'GET'
    }
  }
end
