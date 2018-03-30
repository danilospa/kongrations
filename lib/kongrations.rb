# frozen_string_literal: true

require_relative './kongrations/migration'
require_relative './kongrations/migration_data'
require_relative './kongrations/current_environment'

module Kongrations
  def self.run(migrations_folder, env = 'default')
    CurrentEnvironment.load!(env)

    migrations = migrations_to_run(migrations_folder)

    migrations.each do |migration_file|
      migration_name = File.basename(migration_file).gsub('.rb', '')
      migration_content = File.read(migration_file)

      migration = Migration.build(migration_name, env, migration_content)

      response = migration.run

      print "-- Migration #{migration_name} --"
      print response.body
      if response.error?
        print 'Error when executing migration on Kong'
        break
      end
    end
  end

  def self.migrations_to_run(folder)
    migration_files = Dir.glob(File.join(folder, '*.rb'))

    MigrationData.load!
    last_migration = MigrationData.last_migration
    return migration_files if last_migration.nil?

    last_migration_index = migration_files.find_index { |m| m.end_with?("#{last_migration}.rb") }
    migration_files.slice(0, last_migration_index + 1)
  end

  def self.print(data)
    puts data unless test_env?
  end

  def self.test_env?
    ENV['GEM_ENV'] == 'test'
  end
end