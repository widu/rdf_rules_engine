require 'linkeddata'
require 'sparql'

include RDF

class RdfRulesEngine
	attr_accessor :prefix, :graph, :graph_code
	
	def initialize
		@prefix = "PREFIX rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
		PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
		PREFIX owl:  <http://www.w3.org/2002/07/owl#> 
		PREFIX wd: 	  <http://vieslav.pl/RulesToGraphviz#>
		PREFIX bmm:     <http://ikm-group.ch/archiMEO/BMM#>\n"
		@cache_code = {}
		@cache_dependOn = {}
	end

	def term_name(statement)
		if statement.literal?
			statement.to_s
		elsif statement.node?
			statement.to_s
		else
			statement.pname
		end
			 
	end

	def generate_simple_dot(options = {})
		txt_dot = ""
		options[:rdf_graph] ||= @graph
		options[:digraph] ||= true
		if options[:digraph] == true
			txt_dot << "\ndigraph test123 {"
		else
			txt_dot << "\ngraph test123 {"
		end

		options[:rdf_graph].each_statement do |statement|
			
			s = term_name(statement[0])
			o =  term_name(statement[2])

			txt_dot << "\n\"#{s}\"[color=red, shape=doublecircle];"
			if statement[2].literal?
				txt_dot << "\n\"#{o}\"[shape=rectangle];"
			else
				txt_dot << "\n\"#{o}\"[color=blue, shape=circle];"
			end
			txt_dot << "\n\"#{s}\" -> \"#{o}\" [label=\"#{statement[1].pname}\"];"
			
		end
		txt_dot << "}"
	end
	
	def sub_str_replace(string, substring, replace_substring)
		
		while string.include?(substring) do 
				 string[substring] = replace_substring
		end 
		string
	end
	
	def query_sub(code_id)
		query = "CONSTRUCT { 
		code_id wd:text ?code .
		}  
		WHERE 
		{ 
		OPTIONAL {
		code_id wd:hasCodeUnit ?codeU . 
		?codeU wd:text ?code .
		}
		OPTIONAL {
		code_id wd:hasRule ?Rule . 
		?Rule wd:hasCode ?code .
		}
		}"
		
		#while query.include?("code_id") do 
		
		#		 query["code_id"] = code_id
		#end 
		query = sub_str_replace(query, "code_id", code_id)
	end
	
	def is_dependOn?(code_id, graph_code)
		query = @prefix + "Ask {code_id wd:dependOn ?cos .}"
		query = sub_str_replace(query, "code_id", code_id)
		#puts query
		res0 = SPARQL.execute(query, graph_code)
		#puts res0
		res0
	end
	
	def get_single_code(code_id, graph_code)
		if @cache_code[code_id]== nil then
					res = nil
					res = SPARQL.execute(@prefix + query_sub(code_id), graph_code)
					code= []
					res.each_statement do |statement|
						code << @prefix + statement[2].to_s
						#puts "statement:" + code.to_s
					end
					#puts code
					@cache_code[code_id] = code
					code
		else
				@cache_code[code_id]
		end
	end
	
	def get_tree_code(code_id, graph_code, tree_code, n=0)
		#puts "n:" + n.to_s
		tree_code[code_id]= n
		
		
		if is_dependOn?(code_id, graph_code)==true then
			res0 = nil
			n=n+1
			#puts n
			query = @prefix + "CONSTRUCT {code_id wd:dependOn ?cos .} WHERE {code_id wd:dependOn ?cos .}"
			query = sub_str_replace(query, "code_id", code_id)
			#puts query
			res0 = SPARQL.execute(query, graph_code)
			#puts res0.count
			
			res0.each_statement do |statement|
				st = statement[2].pname
				ost = st.size
				pier = st.index("#") + 1
				#puts st[pier..ost]
				st = "wd:" + st[pier..ost]
				get_tree_code(st, graph_code, tree_code, n)
			end
			
			#puts res0
		end
		#tree_code
	end
	
	def get_code(code_id, graph_code)
		code = []
		if @cache_dependOn.has_key?(code_id) == false then
			tree_code = {}
			
			get_tree_code(code_id, graph_code,  tree_code, 0)
			#@cache_dependOn[code_id] = tree_code
			#puts @cache_dependOn
			ar = tree_code.values
			n = ar.max
			#puts n.to_s
			while n >= 0 do
				code_list = tree_code.select {|key, value| value == n} 
				#puts n.to_s
				code << code_list.keys
				
				n=n-1
			end	
			@cache_dependOn[code_id] = code
		else
			code = @cache_dependOn[code_id]
		end
			
		#puts code
		code
	end
	
	def execute(code_id, graph=@graph, graph_code=@graph_code, zm1=nil )
		res = RDF::Graph.new
		graph_l = RDF::Graph.new
		graph_l << graph
		get_code(code_id, graph_code).each do |c|
			#puts "c:"+ c.to_s
			graph_l << res
			c.each do |c1|
				#puts "c1:" + c1
				get_single_code(c1, graph_code).each do |c2|
					#puts c2
					if zm1 != nil then
						c2 = sub_str_replace(c2, "zm1", zm1)
					end
					res << SPARQL.execute(c2, graph_l) 
				end
			end
		
		end
		res
	end
end