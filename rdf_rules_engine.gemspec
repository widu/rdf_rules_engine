
Gem::Specification.new do |s|
	s.name = 'rdf_rules_engine'
	s.version = '0.0.0'
	s.date = '2016-08-18'
	s.summary = "Rules Engine"
	s.description = "Rules Engine"
	s.authors = ["WiDu"]
	s.email = 'wdulek@gmail.com'
	s.files = ["lib/rdf_rules_engine.rb"]
	s.homepage = 'https://github.com/widu/rdf_rules_engine'
	s.license = 'MIT'
	s.add_runtime_dependency "linkeddata"
	s.add_runtime_dependency "sparql"
end

