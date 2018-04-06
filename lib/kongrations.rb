# frozen_string_literal: true

require 'kongrations/version'
require 'kongrations/migration'
require 'kongrations/migration_data'
require 'kongrations/current_environment'

module Kongrations
  def self.run(env = 'default')
    CurrentEnvironment.load!(env)

    migrations = migrations_to_run

    migrations.each do |migration_file|
      migration_name = File.basename(migration_file)
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

  def self.migrations_to_run
    folder = CurrentEnvironment.migrations_folder
    migration_files = Dir.glob(File.join(folder, '*.rb'))

    MigrationData.load!
    last_migration = MigrationData.last_migration
    return migration_files if last_migration.nil?

    last_migration_index = migration_files.find_index { |m| m.end_with?(last_migration) }
    migration_files.slice!(0, last_migration_index + 1)
    migration_files
  end

  def self.print(data)
    puts data unless test_env?
  end

  def self.test_env?
    ENV['GEM_ENV'] == 'test'
  end
end
