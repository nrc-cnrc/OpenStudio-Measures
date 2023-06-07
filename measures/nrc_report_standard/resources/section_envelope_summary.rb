# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Envelope summary
  class EnvelopeSummary < ReportSection
    def initialize(btap_data:, qaqc_data:, standard:, runner:)

      # Extract additional information required and add to btap_data.
      btap_data.merge! additional_btap_data(qaqc_data)

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

      #  Sometimes the btap look up returns a nil object. Need a zero in this case.
      nil_zero = lambda do |value|
        return value ? value.to_f : 0.0
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

      # Calculate UA value for reporting.
      ua =  btap_data[:bldg_outdoor_walls_area_m2] *nil_zero.call(btap_data[:"env_outdoor_walls_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_outdoor_roofs_area_m2] *nil_zero.call(btap_data[:"env_outdoor_roofs_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_outdoor_floors_area_m2]*nil_zero.call(btap_data[:"env_outdoor_floors_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_ground_walls_area_m2]  *nil_zero.call(btap_data[:"env_ground_walls_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_ground_roofs_area_m2]  *nil_zero.call(btap_data[:"env_ground_roofs_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_ground_floors_area_m2] *nil_zero.call(btap_data[:"env_ground_floors_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_windows_area_m2]       *nil_zero.call(btap_data[:"env_outdoor_windows_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_doors_area_m2]         *nil_zero.call(btap_data[:"env_outdoor_doors_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_overhead_doors_area_m2]*nil_zero.call(btap_data[:"env_outdoor_overhead_doors_average_conductance-w_per_m_sq_k"])
      ua += btap_data[:bldg_skylights_area_m2]     *nil_zero.call(btap_data[:"env_skylights_average_conductance-w_per_m_sq_k"])
      runner.registerValue('ua_value', (ua).signif(4), 'W/K')
      total_area =  btap_data[:bldg_outdoor_walls_area_m2]
      total_area += btap_data[:bldg_outdoor_roofs_area_m2]
      total_area += btap_data[:bldg_outdoor_floors_area_m2]
      total_area += btap_data[:bldg_ground_walls_area_m2]
      total_area += btap_data[:bldg_ground_roofs_area_m2]
      total_area += btap_data[:bldg_ground_floors_area_m2]
      total_area += btap_data[:bldg_windows_area_m2]
      total_area += btap_data[:bldg_doors_area_m2]
      total_area += btap_data[:bldg_overhead_doors_area_m2]
      total_area += btap_data[:bldg_skylights_area_m2]
      ua_normalized = ua/total_area
      runner.registerValue('ua_normalized', (ua_normalized).signif(4), 'W/m2K')
    end

    # Building envelope areas
    def additional_btap_data(qaqc_data)
      data = { bldg_outdoor_walls_area_m2: qaqc_data[:envelope][:outdoor_walls_area_m2],
             bldg_outdoor_roofs_area_m2: qaqc_data[:envelope][:outdoor_roofs_area_m2],
             bldg_outdoor_floors_area_m2: qaqc_data[:envelope][:outdoor_floors_area_m2],
             bldg_ground_walls_area_m2: qaqc_data[:envelope][:ground_walls_area_m2],
             bldg_ground_roofs_area_m2: qaqc_data[:envelope][:ground_roofs_area_m2],
             bldg_ground_floors_area_m2: qaqc_data[:envelope][:ground_floors_area_m2],
             bldg_windows_area_m2: qaqc_data[:envelope][:windows_area_m2],
             bldg_doors_area_m2: qaqc_data[:envelope][:doors_area_m2],
             bldg_overhead_doors_area_m2: qaqc_data[:envelope][:overhead_doors_area_m2],
             bldg_skylights_area_m2: qaqc_data[:envelope][:skylights_area_m2]
      }
    end
  end
end