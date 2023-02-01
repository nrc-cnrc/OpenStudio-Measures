# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Infiltration summary
  class InfiltrationSummary < ReportSection
    def initialize(btap_data:, standard:)
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
end