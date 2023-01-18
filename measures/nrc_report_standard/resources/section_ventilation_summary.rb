# Sections of report created here.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Ventilation summary
  class VentilationSummary < ReportSection
    def initialize(btap_data:, standard:, sqlFile:, model:)
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
end