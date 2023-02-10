# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Lighting summary
  class LightingSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil)
      @content = { title: "Lighting Summary" }
      @content[:introduction] = "The following is a summary of the lighting per area in the model."

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Lighting Overview.")

      # Extract data from hash and ensure it has keys as symbols.
      data = Array.new
      data << ["Space Name", "Space Type Name", "Lighting", "NECB Reference Lighting"]
      data << [" ", " ", "W/m<sup>2</sup>", "W/m<sup>2</sup>"]

      btap_data[:space_table].each do |space|
        space.transform_keys!(&:to_sym)
        space_name = space[:space_name]
        building_type = space[:building_type]
        space_type_name = space[:space_type_name]

        # For dwelling units they will have unique space types (see NECB2011/autozone.rb line ~250 in openstudio-standards)
        # Hack off the number at the end of the name.
        if space_type_name.include? "Dwelling unit"
          space_type_name.tr("0-9", "")
        end

        # In btap_data the building_type is added to the space type name (unless its a whole building).
        if space_type_name.include? building_type
          btap_data_space_type_name = "#{space_type_name}"
        else
          btap_data_space_type_name = "#{building_type}" + " " + "#{space_type_name}"
        end
        puts "******** #{btap_data_space_type_name}"

        # Get LPD from btap_data.
        btap_data_sapce_type = btap_data[:space_type_table].detect { |s| (s['name'] == btap_data_space_type_name) }
        lighting_w_per_m_sq = btap_data_sapce_type["lighting_w_per_m_sq"]

        # Get LPD from NECB.
        spacetype_data = standard.standards_data['tables']['space_types']['table']
        File.open('./spacetype_data.json', 'w') { |f| f.write(JSON.pretty_generate(spacetype_data, allow_nan: true)) }
        puts "Wrote file spacetype_data.json in #{Dir.pwd} "

        # btap_data has building type included in space type name for whole building definitions. Treat that case seperately.
        if space_type_name.include? building_type
          space_type_properties = spacetype_data.detect { |s| (s['building_type'] == building_type) && (s['space_type'] == "WholeBuilding") }
        else
          space_type_properties = spacetype_data.detect { |s| (s['building_type'] == building_type) && (s['space_type'] == space_type_name) }
        end
        
        # Convert from W/ft2 to W/m2 (*** change to use internal openstudio methods)
        necb_lighting_per_area_ft2 = space_type_properties["lighting_per_area"]
        necb_lighting_per_area = necb_lighting_per_area_ft2 * 10.76391041671
        data << [space_name, space_type_name, lighting_w_per_m_sq, necb_lighting_per_area]
      end
      table.data = data
      add_table_or_chart(table)
    end
  end


end

