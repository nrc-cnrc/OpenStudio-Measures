# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Server summary
  class ServerSummary < ReportSection
    def initialize(btap_data:, qaqc_data:)

      # Extract additional information required and add to btap_data.
      btap_data.merge! additional_btap_data(qaqc_data)

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

    def additional_btap_data(qaqc_data)
      data = { simulation_openstudio_version: qaqc_data[:openstudio_version].split('+')[0],
             simulation_openstudio_revision: qaqc_data[:openstudio_version].split('+')[1],
             simulation_energyplus_version: qaqc_data[:energyplus_version]
      }
    end
  end
end