require 'rspec'
require 'klarity'

RSpec.describe 'Integration tests' do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe 'module handling' do
    it 'detects calls within nested class definitions in modules' do
      result = Klarity.analyze(fixtures_path)

      expect(result['UserManagement::Profile']).to be_a(Hash)
      expect(result['UserManagement::Profile'][:messages]).to include('Storage')
      expect(result['UserManagement::Profile'][:messages]).to include('Logger')
    end

    it 'detects calls from module class methods' do
      result = Klarity.analyze(fixtures_path)

      expect(result['UserManagement']).to be_a(Hash)
      expect(result['UserManagement'][:messages]).to include('Database')
    end

    it 'handles classes that include modules' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Administrator']).to be_a(Hash)
      expect(result['Administrator'][:messages]).to include('User')
      expect(result['Administrator'][:messages]).to include('NotificationService')
    end
  end

  describe 'deduplication' do
    it 'ensures each class appears only once in messages' do
      result = Klarity.analyze(fixtures_path)

      database_calls = result.select { |_, deps| deps[:messages].include?('Database') }

      expect(database_calls.keys.count).to eq(4)
    end
  end
end
