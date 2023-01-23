# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Energy summary
  class EnergySummary < ReportSection
    def initialize(btap_data:, runner:)
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
      eui = btap_data[:energy_eui_total_gj_per_m_sq] / 0.0036 # kWh/m2
      data << ["Total EUI", (eui * fa).signif, (eui).signif]
      table.data = data

      add_table_or_chart(table)

	  # Pass recovered values to the output variables in the measure.
      runner.registerValue('total_site_energy_normalized', (eui).signif(4), 'kWh/m2')
      runner.registerValue('total_site_energy', (eui*fa).signif(4), 'kWh')
      runner.registerValue('annual_electricity_use', ((btap_data[:energy_eui_electricity_gj_per_m_sq]) * fa / 0.0036).signif(4), 'kWh')
      runner.registerValue('annual_natural_gas_use', ((btap_data[:energy_eui_natural_gas_gj_per_m_sq]) * fa / 0.0036).signif(4), 'kWh')
    end
  end
end