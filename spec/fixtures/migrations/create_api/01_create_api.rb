# frozen_string_literal: true

create_api do |api|
  api.payload = {
    name: 'api name',
    upstream_url: 'http://www.uol.com.br',
    uris: '/v2/teste'
  }
end
