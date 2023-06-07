# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Lighting summary
  class LightingSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil, model: model = nil)

      # Extract additional information required and add to btap_data.
      btap_data.merge! additional_btap_data(btap_data, model)

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

        # In btap_data the building_type is added to the space type name (unless its a whole building).
        if space_type_name.include? building_type
          btap_data_space_type_name = "#{space_type_name}"
        else
          btap_data_space_type_name = "#{building_type}" + " " + "#{space_type_name}"
        end

        # Get LPD from btap_data.
        btap_data_sapce_type = btap_data[:space_type_table].detect { |s| (s['name'] == btap_data_space_type_name) }
        lighting_w_per_m_sq = btap_data_sapce_type["lighting_w_per_m_sq"]

        # Get LPD from NECB. (File writing for debugging only)
        spacetype_data = standard.standards_data['tables']['space_types']['table']
        #File.open('./spacetype_data.json', 'w') { |f| f.write(JSON.pretty_generate(spacetype_data, allow_nan: true)) }

        # btap_data has building type included in space type name for whole building definitions. Treat that case seperately.
        space_type_properties = nil
        if space_type_name.include? building_type
          space_type_properties = spacetype_data.detect { |s| (s['building_type'] == building_type) && (s['space_type'] == "WholeBuilding") }
        else
          space_type_properties = spacetype_data.detect { |s| (s['building_type'] == building_type) && (s['space_type'] == space_type_name) }
        end
        
        # Catch cases where nothing is returned for the NECB reference and convert from W/ft2 to W/m2.
        if space_type_properties
          necb_lighting_per_area_ft2 = space_type_properties["lighting_per_area"]
          necb_lighting_per_area = OpenStudio.convert(necb_lighting_per_area_ft2, 'W/ft^2', 'W/m^2').get
          data << [space_name, space_type_name, lighting_w_per_m_sq.signif, necb_lighting_per_area.signif]
        else
          data << [space_name, space_type_name, lighting_w_per_m_sq.signif, "unknown"]
        end
      end
      table.data = data
      add_table_or_chart(table)
    end

    # Gather additional data required for the report. 
    def additional_btap_data(btap_data, model)

      data = []

      # Go through btap_data and add space_type_standard to each space type.
      btap_data[:space_table].each do |space|
        space_name = space[:space_name]
        space_type_name = space[:space_type_name]

        # Find the space type in the model and get the standard from that.
        stbn = model.getSpaceTypeByName(space_type_name)
        sst = "unknown"
        sbt = "unknown"
        puts "#{stbn}".green
        if stbn.is_initialized then 
          st = stbn.get
          puts "#{st}".blue
          puts "#{st.standardsSpaceType}".yellow
          puts "#{st.standardsSpaceType.class}".red
          if st.standardsSpaceType.is_initialized then
            sst = st.standardsSpaceType.get
            sbt = st.standardsBuildingType.get
          end
        end
        puts "#{space_name}, #{space_type_name}, #{sst}".pink
        space["standards_space_type"] = sst
        space["standards_building_type"] = sbt
        data << space
      end
      puts "#{data}".pink
      return {"space_table": data}
    end
  end
end

