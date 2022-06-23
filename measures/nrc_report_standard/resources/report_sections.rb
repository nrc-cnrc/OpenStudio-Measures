# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Interface class. Defines all possible content and interface to concrete section objects.
  # The section has a title and overall description. It then has an array of tables and charts.
  class ReportSection
    attr_reader :content

    def initialize()
      @content = { title: nil, introduction: nil, tables_and_charts: nil } # The initialisation does nothing, just a way to highlight the expected keys.
    end

    def add_table_or_chart(table_or_chart)
      (@content[:tables_and_charts] ||= []) << table_or_chart # Fancy way of creating the key or adding to the existing key.
    end

    def to_json(*args)
      {
        :class => self.class.name,
        :content => content
      }.to_json(*args)
    end
  end

  # Template for a table. Can be wither by row or by column (default is columns will be the titles and
  #  rows will have the data, thus by_row=false and row_names will be empty)
  class ReportTable
    attr_writer :data, :description

    def initialize(by_row: by_row = false, units: units = false, caption: nil)
      @table = { by_row: by_row, units: units, caption: caption, data: nil, description: nil }
    end

    def content
      # Ensure that the content of the table is up to date. Return the table object.
      @table.merge!(data: @data)
      @table.merge!(description: @description)
    end

    def to_json(*args)
      {
        :class => self.class.name,
        :content => content
      }.to_json(*args)
    end
  end

  # Server summary
  class ServerSummary < ReportSection
    def initialize(btap_data: btap_data = nil)
      @content = { title: "Summary of Server Configuration" }
      @content[:introduction] = "The following is a summary of the server and OpenStudio components used in the simulation."

      # Define the table content of this section. # Add URL and sha. These are in the qaqc json.
      table = ReportTable.new(caption: "Server summary.")
      data = Array.new
      data << ["Tool", "Version", "Revision"] #, "Repository"]
      data << ["OpenStudio-Standards", btap_data[:simulation_os_standards_version], btap_data[:simulation_os_standards_revision]]
      data << ["EnergyPlus", btap_data[:simulation_energyplus_version], "-"]
      data << ["OpenStudio-Server", btap_data[:simulation_openstudio_version], btap_data[:simulation_openstudio_revision]]
      table.data = data
      table.description = "Description of the server summary table."

      add_table_or_chart(table)
    end
  end

  # Model summary
  class ModelSummary < ReportSection
    def initialize(btap_data: btap_data = nil)
      @content = { title: "Model overview" }
      @content[:introduction] = "The following is a summary of the model."

      # Define the table content of this section. # Add URL and sha. These are in the qaqc json.
      table = ReportTable.new(by_row: true, units: true, caption: "Model Overview.") # Col one will be in bold, two in italics
      data = Array.new
      data << ["Building name", "", btap_data[:bldg_name]]
      data << ["Standard archetype", "", btap_data[:bldg_standards_building_type]]
      data << ["Conditioned floor area", "m<sup>2</sup>", btap_data[:bldg_conditioned_floor_area_m_sq].signif]
      data << ["FDWR", "%", btap_data[:bldg_fdwr].signif]
      data << ["SRR", "%", btap_data[:bldg_srr].signif]
      data << ["Volume", "m<sup>3</sup>", btap_data[:bldg_volume_m_cu].signif]
      data << ["Number of above grade stories", "", btap_data[:bldg_standards_number_of_above_ground_stories]]
      data << ["Principle heating fuel", "", btap_data[:energy_principal_heating_source]]
      table.data = data

      add_table_or_chart(table)
    end
  end

  # Energy summary
  class EnergySummary < ReportSection
    def initialize(btap_data: btap_data = nil)
      @content = { title: "Energy End Use Overview" }
      @content[:introduction] = "The following is a summary of the energy end use from the simulation."

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Energy Overview.")

      # Multipliers needed for the table
      fa = btap_data[:bldg_conditioned_floor_area_m_sq]

      # Extract data from hash and ensure it has keys as symbols.
      data = Array.new
      data << ["End Use", "Energy", "EUI"]
      data << [" ", "kWh", "kWh/m<sup>2</sup>"]
      data << ["Heating", ((btap_data[:energy_eui_heating_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_heating_gj_per_m_sq]) / 0.0036).signif]
      data << ["Cooling", ((btap_data[:energy_eui_cooling_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_cooling_gj_per_m_sq]) / 0.0036).signif]
      data << ["Fans", ((btap_data[:energy_eui_fans_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_fans_gj_per_m_sq]) / 0.0036).signif]
      data << ["Interior Equipment", ((btap_data[:'energy_eui_interior equipment_gj_per_m_sq']) * fa / 0.0036).signif, ((btap_data[:'energy_eui_interior equipment_gj_per_m_sq']) / 0.0036).signif]
      data << ["Pumps", ((btap_data[:energy_eui_pumps_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_pumps_gj_per_m_sq]) / 0.0036).signif]
      data << ["Water Systems", ((btap_data[:"energy_eui_water systems_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_water systems_gj_per_m_sq"]) / 0.0036).signif]
      data << ["Interior Lighting", ((btap_data[:"energy_eui_interior lighting_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_interior lighting_gj_per_m_sq"]) / 0.0036).signif]
      #data << ["Heat Recovery", ((btap_data[:"energy_eui_heat recovery_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_heat recovery_gj_per_m_sq"]) / 0.0036).signif]
      data << ["Total EUI", ((btap_data[:energy_eui_total_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_total_gj_per_m_sq]) / 0.0036).signif]
      table.data = data

      add_table_or_chart(table)
    end
  end

  # Envelope summary
  class EnvelopeSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil)
      @content = { title: "Envelope Overview" }
      @content[:introduction] = "The following is a summary of the building envelope."

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Envelope Overview.")

      # Need hdd to get code values for R-values.
      hdd = btap_data[:location_necb_hdd]

      # Lambdas are preferred over methods in methods for small utility methods.
      #  Retrieve the prescriptive value from the standard.
      std_lookup = lambda do |surface_type|
        return eval(standard.model_find_objects(standard.standards_data['surface_thermal_transmittance'], surface_type)[0]['formula'])
      end

      #  Sometimes the btap look up returns a nil object. Do not send this to signif.
      nil_signif = lambda do |value, digits = 3|
        return value ? value.signif(digits) : value
      end

      # Extract data from hash and ensure it has keys as symbols. Note need "" as there is a - in the name.
      data = Array.new
      data << ["Surface Type", "Area", "Average Conductance", "#{standard.template} reference conductance"]
      data << [" ", "m<sup>2</sup>", "W/m<sup>2</sup>K", "W/m<sup>2</sup>K"]
      data << ["Above grade walls", btap_data[:bldg_outdoor_walls_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_walls_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Wall' }).signif]
      data << ["Above grade roofs", btap_data[:bldg_outdoor_roofs_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_roofs_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'RoofCeiling' }).signif]
      data << ["Above grade floors", btap_data[:bldg_outdoor_floors_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_floors_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Floor' }).signif]
      data << ["Below grade walls", btap_data[:bldg_ground_walls_area_m2].signif,
               nil_signif.call(btap_data[:"env_ground_walls_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Ground', 'surface' => 'Wall' }).signif]
      data << ["Below grade roofs", btap_data[:bldg_ground_roofs_area_m2].signif,
               nil_signif.call(btap_data[:"env_ground_roofs_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Ground', 'surface' => 'RoofCeiling' }).signif]
      data << ["Below grade floors", btap_data[:bldg_ground_floors_area_m2].signif,
               nil_signif.call(btap_data[:"env_ground_floors_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Ground', 'surface' => 'Floor' }).signif]
      data << ["Windows", btap_data[:bldg_windows_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_windows_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Window' }).signif]
      data << ["Doors", btap_data[:bldg_doors_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_doors_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Door' }).signif]
      data << ["Overhead doors", btap_data[:bldg_overhead_doors_area_m2].signif,
               nil_signif.call(btap_data[:"env_outdoor_overhead_doors_average_conductance-w_per_m_sq_k"]),
               std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Door' }).signif]
      if ["NECB2011", "NECB2015", "NECB2017"].include?(standard.template) then
        # Skylights were treated as windows in these versions of NECB.
        data << ["Skylights", btap_data[:bldg_skylights_area_m2].signif,
                 nil_signif.call(btap_data[:"env_skylights_average_conductance-w_per_m_sq_k"]),
                 std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Window' }).signif]
      else
        data << ["Skylights", btap_data[:bldg_skylights_area_m2].signif,
                 nil_signif.call(btap_data[:"env_skylights_average_conductance-w_per_m_sq_k"]),
                 std_lookup.call({ 'boundary_condition' => 'Outdoors', 'surface' => 'Skylight' }).signif]
      end
      #data << ["FDWR", "%", btap_data[:env_fdwr].signif, standard.get_standards_constant('skylight_to_roof_ratio_max_value') * 100.0]
      #data << ["SRR", "%", btap_data[:env_srr].signif, standard.get_standards_constant('skylight_to_roof_ratio_max_value') * 100.0]
      table.data = data

      add_table_or_chart(table)
    end
  end

  # Infiltration summary
  class InfiltrationSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil)
      @content = { title: "Infiltration Overview" }
      @content[:introduction] = "The following is a summary of the infiltration."

      # Recover infiltration rate from the standard.
      inf_rate = standard.get_standards_constant('infiltration_rate_m3_per_s_per_m2')

      # Lambdas are preferred over methods in methods for small utility methods.
      #  Sometimes the btap look up returns a nil object. Do not send this to signif.
      nil_signif = lambda do |value, digits = 3|
        return value ? value.signif(digits) : value
      end

      # Define the table content of this section.
      table = ReportTable.new(by_row: true, units: true, caption: "Infiltration Overview.")

      # Extract data from hash and ensure it has keys as symbols. Note need "" as there is a - in the name.
      data = Array.new
      data << ["Reference rate (#{standard.template})", "L/s/m<sup>2</sup> @ 5 Pa", inf_rate]
      data << ["Reference flow (#{standard.template})", "L/s @ 5 Pa", nil_signif.call(inf_rate * btap_data[:bldg_exterior_area_m_sq])]
      table.data = data
      table.description = "Table <caption> provides a high level summary of the infiltration rate defined in the model and the
	      reference rate in the standard used to create the model."
      add_table_or_chart(table)

      # Space by space table.
      table = ReportTable.new(units: true, caption: "Infiltration by space.")

      # Extract data from hash and ensure it has keys as symbols. Note need "" as there is a - in the name.
      data = Array.new
      data << ["Space name", "Infiltration rate", "Exterior wall area", "Infiltration flow"]
      data << [" ", "L/s/m<sup>2</sup> @ 5 Pa", "m<sup>2</sup>", "L/s @ 5 Pa"]
      total_area = 0.0
      total_flow = 0.0
      btap_data[:space_table].each do |space|
        space.transform_keys!(&:to_sym)
        puts "#{space[:is_conditioned]}".red
        #if space[:is_conditioned] == "Yes" then
        area = space[:exterior_wall_area]
        rate = space[:infiltration_flow_per_m_sq]
        flow = area * rate
        data << [space[:space_name], rate.signif, area.signif, flow.signif]
        total_area += area
        total_flow += flow
        #end
      end
      data << ["Totals", "", total_area.signif, total_flow.signif]
      table.data = data
      table.description = "Table <caption> provides a breakdown of the infiltration by space in the model. Currently in this report
	      the flow is only calculated for exterior walls. Other exposed surfaces will be added soon."
      add_table_or_chart(table)
    end
  end

  # Ventilation summary
  class VentilationSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil, sqlFile: sqlFile = nil, model: model = nil)
      @content = { title: "Ventilation Overview" }
      @content[:introduction] = "The following is a summary of the space ventilation in the model."

      # Lambdas are preferred over methods in methods for small utility methods.
      #  Sometimes the btap look up returns a nil object. Do not send this to signif.
      nil_signif = lambda do |value, digits = 3|
        return value ? value.signif(digits) : value
      end

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Ventilation Overview.")

      # Extract data from hash and ensure it has keys as symbols. Note need "" if there is a - in the symbol.
      data = Array.new
      data << ["Space name", "Zone name", "Air Loop Name", "Ventilation rate", "Volume", "Air change rate"]
      data << [" "," "," ", "m<sup>3</sup>/s", "m<sup>3</sup>", "/hr"]

      # Thermal zones
      rate = 0.0
      volume = 0.0
      total_volume = 0.0
      total_rate = 0.0
      zones = model.getThermalZones
      zones.sort.each do |zone|
        zone_name = zone.name.get
        model.getAirLoopHVACs.each do |air_loop|
          if air_loop.thermalZones.include?(zone)
            air_loop_name = air_loop.name.get
            query = "SELECT Value FROM tabulardatawithstrings WHERE ReportName='Standard62.1Summary' and TableName='Zone Ventilation Parameters' and RowName= '#{zone_name.to_s.upcase}' and ColumnName= 'Breathing Zone Outdoor Airflow - Vbz'"
            rate = model.sqlFile.get.execAndReturnFirstDouble(query)
            rate=rate.to_f
            btap_data_space_type = btap_data[:space_table].detect{|s|(s[:thermal_zone_name] == zone_name.to_s)}
            volume = btap_data_space_type[:volume].to_f
            space_name = btap_data_space_type[:space_name]
            ach = 3600.0 * rate / volume
            data << [space_name, zone_name, air_loop_name, rate.signif, volume.signif, ach.signif]
            total_volume += volume
            total_rate += rate
          end
        end
      end

      data << ["Totals", "", "",total_rate.signif, total_volume.signif, (3600.0 * total_rate / total_volume).signif]
      table.data = data
      table.description = "Table <caption> provides a breakdown of the ventilation by space in the model. -1 represents an
	      error in retrieving the data for the energy plus sql file."
      add_table_or_chart(table)
    end
  end
  
    # Lighting summary
  class LightSummary < ReportSection
    def initialize(btap_data: btap_data = nil, standard: standard = nil)
      @content = { title: "Lighting Summary" }
      @content[:introduction] = "The following is a summary of the lighting per area in the model."

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Lighting Overview.")

      # Extract data from hash and ensure it has keys as symbols.
      data = Array.new
      data << ["Space Name", "Space Type Name", "Lighting", "NECB 2017 Reference Lighting"]
      data << [" ", " ", "W/m<sup>2</sup>", "W/m<sup>2</sup>"]

      btap_data[:space_table].each do |space|
        space.transform_keys!(&:to_sym)
        space_name = space[:space_name]
        building_type = space[:building_type]
        space_type_name = space[:space_type_name]

        # In btap_data the building_type is added to the space type name
        btap_data_space_type_name = "#{building_type}" + " " + "#{space_type_name}"

        # Get LPD from btap_data
        btap_data_sapce_type = btap_data[:space_type_table].detect { |s| (s['name'] == btap_data_space_type_name) }
        lighting_w_per_m_sq = btap_data_sapce_type["lighting_w_per_m_sq"]

        # Get LPD from NECB 2017 Standards
        spacetype_data = standard.standards_data['tables']['space_types']['table']
        space_type_properties = spacetype_data.detect { |s| (s['building_type'] == building_type) && (s['space_type'] == space_type_name) }
        necb_lighting_per_area = space_type_properties["lighting_per_area"]
        data << [space_name, space_type_name, lighting_w_per_m_sq, necb_lighting_per_area]
      end
      table.data = data
      add_table_or_chart(table)
    end
  end

end

