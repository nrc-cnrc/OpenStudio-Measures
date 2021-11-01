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
    @output_folder.to_s
  end

  # Custom way to run an energy plus measure in the test.
  def run_measure(input_arguments, workspace)

    # This will create a instance of the measure you wish to test. It does this based on the test class name.
    measure = get_measure_object()
    measure.use_json_package = @use_json_package
    measure.use_string_double = @use_string_double
    # Return false if can't
    return false if false == measure
    arguments = measure.arguments(workspace)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)
    #Check if

    # Set the arguements in the argument map use json or real arguments.
    if @use_json_package
      argument = arguments[0].clone
      assert(argument.setValue(input_arguments['json_input']), "Could not set value for 'json_input' to #{input_arguments['json_input']}")
      argument_map['json_input'] = argument
    else
      input_arguments.each_with_index do |(key, value), index|
        argument = arguments[index].clone
        if argument_type(argument) == "Double"
          #forces it to a double if it is a double.
          assert(argument.setValue(value.to_f), "Could not set value for #{key} to #{value}")
        else
          assert(argument.setValue(value.to_s), "Could not set value for #{key} to #{value}")
        end
        argument_map[key] = argument
      end
    end
    #run the measure
    measure.run(workspace, runner, argument_map)
    runner.result
    return runner
  end
  
  #Fancy way of getting the measure object automatically. Added check for NRC in measure name.
  def get_measure_object()
    measure_class_name = self.class.name.to_s.match((/(NRC.*)(\_Test)/i) || ((/(BTAP.*)(\_Test)/i))).captures[0]
    btap_measure = nil
    nrc_measure = nil
    eval "btap_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "BTAP"
    eval "nrc_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "Nrc"
    if btap_measure.nil? and nrc_measure.nil?
      if btap_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'BTAPMeasureName_Test' (Note: BTAP is case sensitive.) ".red
      elsif nrc_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'NrcMeasureName_Test' (Note: Nrc is case sensitive.) ".red
      end
      return false
    end
    if btap_measure
      return btap_measure
    else
	  puts "NRC measure\n#{nrc_measure.use_json_package}".green
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
