require 'rdf_rules_engine'

rulesFile  = RDF::Graph.load("./ttl/RulesToGraphviz.ttl")
family = "wd:RulesTableTest2"
factsFile = RDF::Graph.load("./ttl/test1.ttl")

res2 = RDF::Graph.new
engine = RdfRulesEngine.new

engine.prefix = "PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
		PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
		PREFIX owl:  <http://www.w3.org/2002/07/owl#> 
		PREFIX wd: 	  <http://vieslav.pl/RulesToGraphviz#>
		PREFIX bmm:     <http://ikm-group.ch/archiMEO/BMM#>\n"

res2 = engine.execute(family, factsFile, rulesFile)
  # pending # Write code here that turns the phrase above into concrete actions
count = 0
 res2.each_statement do |statement|
   		puts statement
   		count = count + 1
 end
 puts count
 puts res2.count