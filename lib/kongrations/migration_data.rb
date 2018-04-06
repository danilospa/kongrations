# frozen_string_literal: true

require 'kongrations/hash_ext'
require 'kongrations/current_environment'

module Kongrations
  using HashExt

  module MigrationData
    PATH = './migrations-data'

    def self.load!
      @data = File.exist?(file_name) ? JSON.parse(File.read(file_name)) : {}
    end

    def self.last_migration
      @data['last_migration']
    end

    def self.save(migration_name, data)
      @data['last_migration'] = migration_name
      @data.deep_merge!(data) unless data.nil?
      save_file
    end

    def self.data
      @data
    end

    def self.file_name
      "#{PATH}/#{CurrentEnvironment.name}.json"
    end

    def self.save_file
      Dir.mkdir(PATH) unless File.exist?(PATH)
      File.open(file_name, 'w') { |f| f.puts @data.to_json }
    end

    private_class_method :save_file
  end
end
