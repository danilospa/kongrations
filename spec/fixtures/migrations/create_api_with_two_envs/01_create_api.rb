# frozen_string_literal: true

config_env :staging do |e|
  e.payload = 'payload for staging'
end

config_env :production do |e|
  e.payload = 'payload for production'
end

create_api do |api|
  api.payload = env.payload
end
