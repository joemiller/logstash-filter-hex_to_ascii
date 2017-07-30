Gem::Specification.new do |s|
  s.name = 'logstash-filter-hex_to_ascii'
  s.version = '0.2.0'
  s.licenses = ['Apache-2.0']
  s.summary = 'Convert hex-encoded string fields to ASCII'
  s.description = 'Convert hex-encoded string fields to ASCII'
  s.homepage = 'https://github.com/pantheon-systems/logstash-filter-hex_to_ascii'
  s.authors = ['Pantheon']
  s.email = 'joe@pantheon.io'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*', '*.gemspec', '*.md', 'CONTRIBUTORS', 'Gemfile', 'LICENSE', 'NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'input' }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', '>= 1.60', '<= 2.99'
  s.add_development_dependency 'logstash-devutils', '~> 1.0'
end
