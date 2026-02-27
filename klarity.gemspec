# frozen_string_literal: true

require_relative 'lib/klarity/version'

Gem::Specification.new do |spec|
  spec.name = 'klarity'
  spec.version = Klarity::VERSION
  spec.authors = ['Dave Kinkead']
  spec.email = ['dave@kinkead.com.au']

  spec.summary = 'Dependency analysis and mapping for Ruby projects'
  spec.description = 'Klarity analyzes Ruby projects to build dependency graphs showing inheritance, module inclusions, method messages, and dynamic patterns.'
  spec.homepage = 'https://github.com/davekinkead/klarity'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[Gemfile .gitignore])
    end
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'prism', '~> 1.0'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.60'
end
