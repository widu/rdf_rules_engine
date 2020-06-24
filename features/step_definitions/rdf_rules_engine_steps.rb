Given(/^Rules family file: "([^"]*)"$/) do |arg1|
  @rulesFile  = RDF::Graph.load(arg1)
  # pending # Write code here that turns the phrase above into concrete actions
end

Given(/^Rules family name: "([^"]*)"$/) do |arg1|
  @family = arg1
  # pending # Write code here that turns the phrase above into concrete actions
end

Given(/^Fakts file: "([^"]*)"$/) do |arg1|
   @factsFile = RDF::Graph.load(arg1)
  # pending # Write code here that turns the phrase above into concrete actions
end

When(/^The rules engine is run$/) do
	res2 = RDF::Graph.new
	engine = RdfRulesEngine.new
	res2 = engine.execute(@family, @factsFile, @rulesFile)
  # pending # Write code here that turns the phrase above into concrete actions
    @output = 0
     res2.each_statement do |statement|
   		@output = 1
   end
end

Then(/^The output should have "([^"]*)"$/) do |arg1|
  puts @output
   
  #pending # Write code here that turns the phrase above into concrete actions
end