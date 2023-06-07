# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Energy summary. 
  # This section contains two tables. (1) Energy use summary; (2) Simulation outputs summary.
  class EnergySummary < ReportSection
    def initialize(btap_data:, qaqc_data:, runner:)

      # Extract additional information required and add to btap_data.
      btap_data.merge! additional_btap_data(qaqc_data)

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
      data << ["Interior Lighting", ((btap_data[:"energy_eui_interior lighting_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_interior lighting_gj_per_m_sq"]) / 0.0036).signif]
      data << ["Exterior Lighting", ((btap_data[:energy_eui_exterior_lighting_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_exterior_lighting_gj_per_m2]) / 0.0036).signif]
      data << ["Interior Equipment", ((btap_data[:'energy_eui_interior equipment_gj_per_m_sq']) * fa / 0.0036).signif, ((btap_data[:'energy_eui_interior equipment_gj_per_m_sq']) / 0.0036).signif]
      data << ["Exterior Equipment", ((btap_data[:energy_eui_exterior_equipment_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_exterior_equipment_gj_per_m2]) / 0.0036).signif]
      data << ["Fans", ((btap_data[:energy_eui_fans_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_fans_gj_per_m_sq]) / 0.0036).signif]
      data << ["Pumps", ((btap_data[:energy_eui_pumps_gj_per_m_sq]) * fa / 0.0036).signif, ((btap_data[:energy_eui_pumps_gj_per_m_sq]) / 0.0036).signif]
      data << ["Water Systems", ((btap_data[:"energy_eui_water systems_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_water systems_gj_per_m_sq"]) / 0.0036).signif]
      data << ["Heat Recovery", ((btap_data[:"energy_eui_heat recovery_gj_per_m_sq"]) * fa / 0.0036).signif, ((btap_data[:"energy_eui_heat recovery_gj_per_m_sq"]) / 0.0036).signif]
      data << ["Heat Rejection", ((btap_data[:energy_eui_heat_rejection_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_heat_rejection_gj_per_m2]) / 0.0036).signif]
      data << ["Humidification", ((btap_data[:energy_eui_humidification_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_humidification_gj_per_m2]) / 0.0036).signif]
      data << ["Refrigeration", ((btap_data[:energy_eui_refrigeration_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_refrigeration_gj_per_m2]) / 0.0036).signif]
      data << ["Generators", ((btap_data[:energy_eui_generators_gj_per_m2]) * fa / 0.0036).signif, ((btap_data[:energy_eui_generators_gj_per_m2]) / 0.0036).signif]
      eui = btap_data[:energy_eui_total_gj_per_m_sq] / 0.0036 # kWh/m2
      data << ["Total EUI", (eui * fa).signif, (eui).signif]
      table.data = data
      add_table_or_chart(table)

      # NECB regulated load (normalized).
      eui_regulated = eui - btap_data[:'energy_eui_interior equipment_gj_per_m_sq'] / 0.0036

      # Additional metrics.
      bc_meui = btap_data[:bc_step_code_meui_kwh_per_m_sq]
      runner.registerValue('bc_meui', (bc_meui).signif(4), 'kWh/m2')
      bc_tedi = btap_data[:bc_step_code_tedi_kwh_per_m_sq]
      runner.registerValue('bc_tedi', (bc_tedi).signif(4), 'kWh/m2')
      peak_electrical = btap_data[:energy_peak_electric_w_per_m_sq] / 1000.0
      runner.registerValue('peak_electrical_demand', (peak_electrical).signif(4), 'kW/m2')

      # Pass recovered values to the output variables in the measure.
      runner.registerValue('total_normalized_necb_regulated_loads', (eui_regulated).signif(4), 'kWh/m2')
      runner.registerValue('total_normalized_site_energy', (eui).signif(4), 'kWh/m2')
      total_energy = eui * fa
      puts "#{total_energy}; #{eui}; #{fa}; ".red
      runner.registerValue('total_site_energy', (total_energy).signif(4), 'kWh')
      runner.registerValue('annual_electricity_use', ((btap_data[:energy_eui_electricity_gj_per_m_sq]) * fa / 0.0036).signif(4), 'kWh')
      runner.registerValue('annual_natural_gas_use', ((btap_data[:energy_eui_natural_gas_gj_per_m_sq]) * fa / 0.0036).signif(4), 'kWh')

      # Add another table for the degree days and unmet hours
      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Model Performace Overview.")

      # Extract data from hash and ensure it has keys as symbols.
      data = Array.new
      data << ["Parameter", "Value", "Unit"]
      data << [" ", "kWh", "kWh/m<sup>2</sup>"]
      data << ["HDD", btap_data[:location_epw_hdd].round(1)]
      data << ["CDD", btap_data[:location_epw_cdd].round(1)]
      data << ["Unmet heating hours (occupied)", btap_data[:unmet_hours_heating_during_occupied].round(1)]
      data << ["Unmet cooling hours (occupied)", btap_data[:unmet_hours_heating_during_occupied].round(1)]
      table.data = data
      add_table_or_chart(table)

      # 
      runner.registerValue('hdd', btap_data[:location_epw_hdd].round(1), 'units') # heating degree days
      runner.registerValue('cdd', btap_data[:location_epw_cdd].round(1), 'units') # cooling degree days
      runner.registerValue('unmet_hours_heat_occ', btap_data[:unmet_hours_heating_during_occupied].round(1), 'hours') # unmet hours
      runner.registerValue('unmet_hours_cool_occ', btap_data[:unmet_hours_heating_during_occupied].round(1), 'hours') # unmet hours
    end

    def additional_btap_data(qaqc_data)
      data = { energy_eui_exterior_lighting_gj_per_m2: qaqc_data[:end_uses_eui]["exterior_lighting_gj_per_m2"],
               energy_eui_exterior_equipment_gj_per_m2: qaqc_data[:end_uses_eui]["exterior_equipment_gj_per_m2"],
               energy_eui_heat_rejection_gj_per_m2: qaqc_data[:end_uses_eui]["heat_rejection_gj_per_m2"],
               energy_eui_humidification_gj_per_m2: qaqc_data[:end_uses_eui]["humidification_gj_per_m2"],
               energy_eui_refrigeration_gj_per_m2: qaqc_data[:end_uses_eui]["refrigeration_gj_per_m2"],
               energy_eui_generators_gj_per_m2: qaqc_data[:end_uses_eui]["generators_gj_per_m2"]
      }
    end
  end
end
