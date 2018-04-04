
# frozen_string_literal: true

RSpec.shared_examples 'behaves like a migration' do |migrations_folder, data_to_save = nil|
  let(:migrations_path) { "./spec/fixtures/migrations/#{migrations_folder}" }
  let(:file_name) do
    migration_file = Dir.glob(File.join(migrations_path, '*.rb')).first
    File.basename(migration_file).gsub('.rb', '')
  end
  let(:migration_data) do
    JSON.parse(File.read(Kongrations::MigrationData.file_name), symbolize_names: true)
  end

  before do
    mock_default_config_file(migrations_folder)
    subject.run
  end

  it 'performs correct request' do
    expect(@request_stub).to have_been_requested
  end

  it 'sets correct last_migration value' do
    expect(migration_data[:last_migration]).to eq file_name
  end

  unless data_to_save.nil?
    it 'sets correct custom data' do
      expect(migration_data).to include(data_to_save)
    end
  end
end
