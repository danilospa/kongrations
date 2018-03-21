# frozen_string_literal: true

module MigrationData
  FILE_NAME = './migrations.data'

  def self.load
    @data = if File.exist?(FILE_NAME)
              JSON.parse(File.read(FILE_NAME), symbolize_names: true)
            else
              {}
            end
  end

  def self.last_migration
    @data[:last_migration]
  end

  def self.save(migration_name, data)
    @data.merge!(data) unless data.nil?
    @data[:last_migration] = migration_name
    File.open(FILE_NAME, 'w') do |f|
      f.puts @data.to_json
    end
  end

  def self.data
    @data
  end
end
