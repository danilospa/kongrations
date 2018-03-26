# frozen_string_literal: true

require_relative './hash'

module MigrationData
  FILE_NAME = './migrations.data'

  def self.load
    @data = if File.exist?(FILE_NAME)
              JSON.parse(File.read(FILE_NAME))
            else
              {}
            end
  end

  def self.last_migration
    @data[:last_migration]
  end

  def self.save(migration_name, data)
    @data[:last_migration] = migration_name
    @data.deep_merge!(data) unless data.nil?
    File.open(FILE_NAME, 'w') { |f| f.puts @data.to_json }
  end

  def self.data
    @data
  end
end
