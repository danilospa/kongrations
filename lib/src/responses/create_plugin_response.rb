# frozen_string_literal: true

require_relative '../response'

class CreatePluginResponse < Response
  def data_to_save
    api_name = @request.api_name
    plugin_name = @request.payload[:name]
    plugin_id = body[:id]
    {
      api_name => {
        'plugins' => {
          plugin_name => plugin_id
        }
      }
    }
  end
end
