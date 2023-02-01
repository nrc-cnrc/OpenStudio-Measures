# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Model summary
  class ModelSummary < ReportSection
    def initialize(btap_data:)
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
end