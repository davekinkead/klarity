require 'rspec'
require 'klarity'

RSpec.describe 'Edge cases' do
  let(:fixtures_path) { File.expand_path('fixtures/sample_app', __dir__) }

  describe 'empty class' do
    it 'includes classes with no method calls' do
      result = Klarity.analyze(fixtures_path)

      expect(result['EmptyFile']).to be_a(Hash)
      expect(result['EmptyFile'][:messages]).to eq([])
    end
  end

  describe 'file with syntax errors' do
    it 'gracefully handles files with syntax errors' do
      allow(Klarity::FileScanner)
        .to receive(:scan)
        .and_return([File.join(fixtures_path, 'user.rb'), 'nonexistent_file.rb'])

      expect { Klarity.analyze(fixtures_path) }.not_to raise_error
    end
  end

  describe 'missing directory' do
    it 'handles non-existent directories' do
      result = Klarity.analyze('/nonexistent/directory')
      expect(result).to eq({})
    end
  end
end
