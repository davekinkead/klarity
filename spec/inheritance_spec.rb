require 'rspec'
require 'klarity'

RSpec.describe 'Inheritance and Mixins' do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe 'inheritance detection' do
    it 'detects class inheritance' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Person'][:inherits]).to include('ApplicationRecord')
      expect(result['Admin'][:inherits]).to include('Person')
    end
  end

  describe 'mixin detection' do
    it 'detects include statements' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Person'][:mixins]).to include('ActiveModel::Validations')
      expect(result['Admin'][:mixins]).to include('Auth::Permissions')
    end

    it 'detects extend statements' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Person'][:mixins]).to include('ActiveModel::Naming')
    end

    it 'detects prepend statements' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Admin'][:mixins]).to include('Auditable')
    end

    it 'deduplicates mixins' do
      result = Klarity.analyze(fixtures_path)

      # Count occurrences should be 1 per unique mixin
      admin_mixins = result['Admin'][:mixins]
      expect(admin_mixins.length).to eq(admin_mixins.uniq.length)
    end
  end

  describe 'combined detection' do
    it 'tracks inheritance, mixins, and messages together' do
      result = Klarity.analyze(fixtures_path)

      person = result['Person']
      expect(person[:inherits]).to include('ApplicationRecord')
      expect(person[:mixins]).to include('ActiveModel::Validations', 'ActiveModel::Naming')
      expect(person[:messages]).to include('Database')
    end
  end
end
