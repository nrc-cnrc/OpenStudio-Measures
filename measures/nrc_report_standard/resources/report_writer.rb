# Strategy implementation of various writers. These are bound to the data structure 
#  created in report_sections.rb
# Includes:
#  html
#  word - requires caracal gem which is disabled for now
#  json - saves the raw data. Can be processed seperately into a report.

# Define these in the scope of the measure's class.
class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

# Context interface definition.
  class Writer  
    def initialize(strategy)
      @strategy=strategy
    end
    def write(data)
      # Generic writing code can go here (if any)
      result=@strategy.do_writing(data)
    end
  end

# Strategy interface definition.
  class Strategy
    def do_writing(data)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end

# Concrete strategies.
  class Html_writer < Strategy
    def do_writing(data)
	
	# TO DO 
	#  - detect the phrase <caption> in a description and add an href. Need to create the anchor as well.
	#  - create a table of contents (section titles as anchors and listed in the toc (as href's).
  
      # Format the content of data into html (we do the heavy lifting here rather than in the html.in file).
	  # The html.in file is expecting one variable called output to have the entire contents of the file.
	  # data is an array of sections that will populate the report.
      # each section contains {title: nil, introduction: nil, table: nil, chart: nil, caption: nil, description: nil}
	  # tables contain {by_row: by_row, column_names: nil, row_names: nil, units: nil, data: nil}
      output = ""
	  data.each do |section|
	    content = section.content
	    output << "<h2>#{content[:title]}</h2>"
	    output << "<p>#{content[:introduction]}</p>"
		if content[:tables_and_charts] != nil
		  content[:tables_and_charts].each do |table_or_chart|
		    if table_or_chart.class.name.include?("ReportTable") then
			  # Its a table.
			  table_content=table_or_chart.content
	          output << "<p>Table: #{table_content[:caption]}</p>"
		      if table_content[:by_row] == false
                # Table has column headings. First row of data is the column name, second row optionally is the unit.
                skip=1
                output << "<table>"
                output << "<tr>"
                table_content[:data][0].each {|element| output << "<th>#{element}</th>"}
                output << "</tr>"
                if table_content[:units]
                  skip=2
                  output << "<tr>"
                  table_content[:data][1].each {|element| output << "<td><i>#{element}</i></td>"}
                  output << "</tr>"
                end
                table_content[:data].drop(skip).each do |row|
                  output << "<tr>"
                  row.each {|element| output << "<td>#{element}</td>"}
                  output << "</tr>"
                end  
                output << "</table>"
              else
                # Table has row headings (and no column headings). First element of data is the row name, second optionally is the unit.
                output << "<table>"
                table_content[:data].each do |row|
                  output << "<tr>"
                  output << "<th>#{row[0]}</th>"
                  skip=1
                if table_content[:units]
                  skip=2
                  output << "<td><i>#{row[1]}</i></td>"
                end
                row.drop(skip).each {|element| output << "<td>#{element}</td>"}
                output << "</tr>"
                end  
                output << "</table>"
		      end
	          output << "<p>#{table_content[:description]}</p>"
		    elsif ["ReportChart"].include?(table_or_chart.class.name) then
	          output << "<h2>#{content[:chart]}</h2>"
	          output << "<p>Figure: #{content[:caption]}</p>"
	          output << "<p>#{content[:description]}</p>"
		    end
		  end
		end
	  end
	
      # Read in template.
      html_in_path = "#{File.dirname(__FILE__)}/report.html.in"
      html_in = ''
      File.open(html_in_path, 'r') do |file|
        html_in = file.read
      end
	
      # Configure template with variable values.
      renderer = ERB.new(html_in)
      html_out = renderer.result(binding)

      # Write html file.
      html_out_path = 'report.html'
      File.open(html_out_path, 'w') do |file|
        file << html_out
        # make sure data is written to the disk one way or the other.
        begin
          file.fsync
        rescue StandardError
          file.flush
        end
      end
    end
  end
  
  class Word_writer < Strategy
    def do_writing(data)
	  docx = Caracal::Document.new('report.docx')
	  data.each do |section|
	    content = section.content
	    docx.h1("#{content[:title]}")
	    docx.p("#{content[:introduction]}")
		if content[:tables_and_charts] != nil
		  content[:tables_and_charts].each do |table_or_chart|
		    case table_or_chart
			when ReportTable
			  # Its a table.
			  table_content=table_or_chart.content
	          docx.p("Table: #{table_content[:caption]}")
			  
			  # Need to scan table data and replace html tags with the appropriate caracel objects.
			  table_data=table_content[:data]
			  table_data.each do |row|
			    row.replace(row.map! { |cell|
				  case cell
				  when String
				    if cell.include?("<sup>") 
					  #cell.sub!("<sup>","")
					  #cell.sub!("</sup>","")
					  new_cell = Caracal::Core::Models::TableCellModel.new do
					    p do
						  text cell.split("<sup>")[0].to_s
						  text cell.split("<sup>")[1].split("</sup>")[0].to_s do
						    vertical_align 'superscript'
						  end
						  text cell.split("</sup>")[1].to_s
						end
					  end
					  cell = new_cell
					  puts "#{cell}".green
					end
				  end
			      puts "#{cell}".red
				  cell
			    })
			  end
			  puts "#{table_data}".yellow
			  # Now create the Word table.
		      docx.table(table_data)
	          docx.p("#{table_content[:description]}")
			when ReportChart
			  puts "*** ReportChart writing *** Not yet implemented".yellow
			else
			  puts "*** unknown content type ***".yellow
		    end
		  end
		end
	  end
	  docx.save
	end
  end
  
  class Json_writer < Strategy
    def do_writing(data)
      File.open('./report.json', 'w') do |f| 
	    f.write('{')
	    f.write("#{$/}") # OS independent new line, must be between double quotes (hence why its on its own).
	    f.write('"model": "model_name",')
	    f.write("#{$/}")
	    f.write('"content":')
	    f.write("#{$/}")
	    f.write(JSON.pretty_generate(data))
	    f.write("#{$/}")
	    f.write('}')
	  end
      puts "Wrote file json data in #{Dir.pwd} "
	end
  end
end