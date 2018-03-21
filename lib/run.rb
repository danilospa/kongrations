# frozen_string_literal: true

require_relative './src/migration'
require_relative './src/migration_data'

migration_files = Dir["#{__dir__}/migrations/*.rb"]

MigrationData.load
last_migration = MigrationData.last_migration
last_migration_index = migration_files.find_index { |m| m.end_with?("#{last_migration}.rb") }
migration_files.slice!(0, last_migration_index + 1) unless last_migration_index.zero?

migration_files.each do |migration_file|
  file_name = File.basename(migration_file).gsub('.rb', '')

  content = File.read(migration_file)
  migration_class = Class.new(Migration) do
    def initialize(migration_name)
      @migration_name = migration_name
    end
  end
  migration_class.class_eval("def change; #{content}; end", __FILE__, __LINE__)
  migration = migration_class.new(file_name)

  puts "-- Migration #{file_name} --"
  response = migration.run
  puts response.body
  if response.error?
    puts 'Error when executing migration on Kong'
    break
  end
end
