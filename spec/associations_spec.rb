require 'rspec'
require 'klarity'

RSpec.describe 'ActiveRecord Associations' do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe 'association detection' do
    it 'detects belongs_to associations' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to include('Author')
    end

    it 'detects has_many associations' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to include('Comment')
    end

    it 'detects has_one associations' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to include('Metadata')
    end

    it 'detects has_and_belongs_to_many associations' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to include('Tag')
    end

    it 'infers class names from associations' do
      result = Klarity.analyze(fixtures_path)

      expect(result['User'][:associations]).to include('Article', 'Comment')
    end

    it 'handles class_name option' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to include('Taxonomy::Category')
    end

    it 'includes associations in all classes' do
      result = Klarity.analyze(fixtures_path)

      expect(result['Article'][:associations]).to be_an(Array)
      expect(result['Comment'][:associations]).to be_an(Array)
      expect(result['User'][:associations]).to be_an(Array)
    end
  end
end
