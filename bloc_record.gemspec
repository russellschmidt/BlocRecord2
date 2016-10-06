Gem::Specification.new do |s|
	s.name = 'bloc_record'
	s.version = '0.0.0'
	s.date = '2016-10-06'
	s.summary = 'BlocRecord ORM'
	s.description = 'An ActiveRecord-esque ORM adaptor'
	s.authors = ['Russell Schmidt', 'Bloc']
	s.email = 'mail@russellschmidt.net'
	# files is an array of files included in this gem
	# rather than list them out, we use the ls-files command in git
	# 'git ls-files' will output each file on its own line
	# split($/) takes that string of files, separates by newlines, and puts into an array
	s.files = 'git ls-files'.split($/)
	s.require_paths = ["lib"]
	s.homepage = "http://rubygems.org/gems/bloc_record"
	s.license = "MIT"
	s.add_runtime_dependency 'sqlite3', '~> 1.3'
end