# Kongrations

[![Build Status](https://travis-ci.org/danilospa/kongrations.svg?branch=master)](https://travis-ci.org/danilospa/kongrations)
[![Maintainability](https://api.codeclimate.com/v1/badges/90e3435368aaf9b4023a/maintainability)](https://codeclimate.com/github/danilospa/kongrations/maintainability)

## Description

Kongrations is a migrations like for [Kong](https://github.com/Kong/kong) APIs and its associations like consumers and plugins.  
You configure an environment and start creating files that will reproduce the specified changes into Kong using [Kong Admin API](https://getkong.org/docs/0.13.x/admin-api/).

Example of a migration to create an API:
```ruby
create_api do |api|
  api.payload = {
    name: 'my-api',
    uris: '/myapi'
    upstream_url: 'https://myapi.mycompany.com',
  }
end
```

## Why Kongrations?

- Control what happens into Kong APIs.
- Keep track of every change.
- Apply same changes to different environments.

All of this using a readable Ruby syntax to describe the migrations.

## Compatibility

Kongrations was built upon Kong 0.13.x documentation.

## Getting Started

Kongrations depends on Ruby. Make sure you have it installed, then install Kongrations gem.

```ruby
gem install kongrations
```

### Configuring environments

You need to create a file called `kongrations.yml` and specify the desired environments of Kong.
You can use environments variables on the file too.

```yaml
environments:
  - name: default
    kong-admin-url: kong-admin-url.domain.com # Do not include HTTP or HTTPS here.
    kong-admin-api-key: 123456789

  - name: production
    kong-admin-url: kong-admin-url-for-production.domain.com
    kong-admin-api-key: <%= ENV['MY_ENV_VARIABLE'] %>
```

### Working with environments

Kongrations allows you to use parameters to specify differences across environments. You can do it as follows:
```ruby
config_env 'default' do |env|
  env.upstream_url = 'https://myapi-staging.mycompany.com'
  env.retries = 0
end

config_env 'production' do |env|
  env.upstream_url = 'https://myapi.mycompany.com'
  env.retries = 2
end

create_api do |api|
  api.payload = {
    name: 'my-api',
    uris: '/myapi',
    upstream_url: env.upstream_url,
    retries: env.retries
  }
end
```

First, you need to set the variables for your existing environments specified on `kongrations.yml` file.  
Then, you use them through `env` name, like: `env.defined_variable`.

### Basic usage of the migrations

Defined migrations are mapped into HTTP requests to Kong Admin API accordingly to the [documentation](https://getkong.org/docs/0.13.x/admin-api).  
Every request body described oh the Kong Admin API documentation must be set using the `payload` name.

After running the migration, Kongrations create a file on `./migrations-data` for each Kong environment to store its state. This file should be commited into your version control system. Also, it's extremely important not to touch this file directly, since it's crucial for Kongrations to work normally.

Place your migration files inside `./migrations` folder. You can change the default folder putting a `path` key on `kongrations.yml` file.  
You also need to use `.rb` extension on them.

To run the migrations, use Kongrations cli, passing an optional parameter to specify the environment name (default environment name is `default`).  
Examples:
```shell
$ kongrations # runs for default environment
$ kongrations production
```

### Available migrations

#### Create API

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#add-api)
- Usage: pass the request body through `api.payload`.
- Example:
```ruby
create_api do |api|
  api.payload = {
    name: 'my-api',
    uris: '/myapi',
    upstream_url: 'https://myapi.mycompany.com'
  }
end
```

#### Update API

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#update-api)
- Usage: pass your API name right after `change_api` method, then pass the request body through `api.payload`.
- Example:
```ruby
change_api 'api-name' do |api|
  api.payload = {
    upstream_url: 'https://my-api.mycompany.com'
  }
end
```

#### Delete API

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#delete-api)
- Usage: pass your API name right after `delete_api` method.
- Example:
```ruby
delete_api 'api-name'
```

#### Create Plugin

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#add-plugin)
- Usage: pass your API name right after `create_plugin_for_api` method, then pass the request body through `plugin.payload`.
- Example:
```ruby
create_plugin_for_api 'api-name' do |plugin|
  plugin.payload = {
    name: 'cors',
    config: {
      origins: '*',
      methods: 'GET, POST'
    }
  }
end
```

#### Update Plugin

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#update-plugin)
- Usage: pass your API and plugin names right after `change_plugin_for_api` method, then pass the request body through `plugin.payload`.
- Example:
```ruby
change_plugin_for_api 'api-name', 'cors' do |plugin|
  plugin.payload = {
    config: {
      methods: 'GET'
    }
  }
end
```

#### Delete Plugin

- [Kong Admin API Reference](https://getkong.org/docs/0.13.x/admin-api/#delete-plugin)
- Usage: pass your API and plugin names right after `delete_plugin_for_api` method.
- Example:
```ruby
delete_plugin_for_api 'api-name', 'cors'
```
