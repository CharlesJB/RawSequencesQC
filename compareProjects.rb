#!/usr/bin/env ruby

require 'rexml/document'


class Comparator
	def initialize
		@data = Hash.new
		@sources = Array.new
	end

	def produce_html
		puts "<html><head></head><body>"
		@data.each do |project, project_data|
			puts "<div><table border=\"2\"><caption>Project " + project + " </caption>"
			puts "<tbody>"
			puts "<tr><th rowspan=\"2\">Sample</th><th colspan=\""+@sources.size.to_s+"\">Sequences</th></tr>"
			puts "<tr>"
			@sources.each do |source|
				puts "<th>" + source + "</th>"
			end
			puts "</tr>"

			project_data.each do |sample, sample_data|
				puts "<tr><td>"+sample+"</td>"
				@sources.each do |source|
					sequences = sample_data[source]
					puts "<td>" + sequences + "</td>"
				end
				puts "</tr>"
			end

			puts "</tbody>"
			puts "</table><br /><br /><br /></div>"
		end
	
		puts "</body></html>"
	end

	def push_xml_file xml_file

		@sources.push xml_file

		file = File.new xml_file
		root = REXML::Document.new file

		root .elements.each('samples/sample') do |element|

			project = element.elements["projectName"].text
			sample = element.elements["sampleName"].text
			sequences = element.elements["sequences"].text

			unless @data.has_key? project
				@data[project] = Hash.new
			end

			unless @data[project].has_key? sample
				@data[project][sample] = Hash.new
			end

			unless @data[project][sample].has_key? xml_file
				@data[project][sample][xml_file] = sequences
			end
		end
	end
end


arguments = ARGV

if arguments.empty?
	puts "You must provide XML files describing your projects / samples"
	exit
end

comparator = Comparator.new

arguments.each do |xml_file|
	comparator.push_xml_file xml_file
end

comparator.produce_html
