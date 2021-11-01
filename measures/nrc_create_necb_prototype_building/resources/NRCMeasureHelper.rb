# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'

module NRCMeasureHelper
  include BTAPMeasureHelper
end

module NRCMeasureTestHelper
  include BTAPMeasureTestHelper

  # Define the output folder
  @output_folder = Dir.pwd
  def self.setOutputFolder(folder)
    @output_folder = folder
  end
  def self.outputFolder
    @output_folder
  end

  #Fancy way of getting the measure object automatically. Added check for NRC in measure name.
  def get_measure_object()
    measure_class_name = self.class.name.to_s.match((/(NRC.*)(\_Test)/i) || ((/(BTAP.*)(\_Test)/i))).captures[0]
    btap_measure = nil
    nrc_measure = nil
	puts "#{measure_class_name}".yellow
    eval "btap_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "BTAP"
    eval "nrc_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "Nrc"
    if btap_measure.nil? and nrc_measure.nil?
      if btap_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'BTAPMeasureName_Test' (Note: BTAP is case sensitive.) ".red
      elsif nrc_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'NRCMeasureName_Test' (Note: Nrc is case sensitive.) ".red
      end
      return false
    end
    if btap_measure
      return btap_measure
    else
      return nrc_measure
    end
  end
end

# Add significant digits capability to float class.
class Float
  def signif(digits)
    return 0 if self.zero?
    self.round(-(Math.log10(self).ceil - digits))
  end
end
