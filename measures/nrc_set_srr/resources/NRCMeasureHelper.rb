# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'
require 'erb'

module NRCMeasureHelper
  include BTAPMeasureHelper
end

module NRCMeasureTestHelper
  include BTAPMeasureTestHelper

  # Define the output path. Set defaults and remove any existing outputs.
  @output_root_path = File.expand_path("#{File.expand_path(__dir__)}/../tests/output")
  Dir.mkdir @output_root_path unless Dir.exists?(@output_root_path)
  @output_path = @output_root_path
  existing_folders = Dir.entries(@output_root_path) - ['.', '..'] # Remove current folder above from list before deleting!
  existing_folders.each do |entry|
    folder_to_remove = File.expand_path("#{@output_root_path}/#{entry}")
    puts "Removing existing output folder: #{folder_to_remove}".yellow
    FileUtils.rm_rf(folder_to_remove)
  end

  # Define methods to manage output folders.
  def self.resetOutputFolder
    @output_path = @output_root_path
  end

  def self.appendOutputFolder(folder)
    # Append name and validate if specified by the user
    path = @output_root_path + "/" + folder
    validateOutputFolder(path)
  end

  def self.validateOutputFolder(path)
    # This should not be the root_folder.
    # Also check if it exists.
    # By default use the test method name.
    path = File.expand_path(path)
    if path == @output_root_path
      # Append the calling method name and re-validate (need to jump back two methods)
      path = @output_root_path + "/" + caller_locations(1, 2)[1].label.split.last
      validateOutputFolder(path)
    elsif File.exist?(path)
      # Create a numbered subfolder. First check if there is a numbered folder.
      path = path.split(/--/).first
      count = Dir.glob("#{path}*").count
      path = path + "--#{count}"
      validateOutputFolder(path)
    else
      @output_path = path
    end
    @output_path.to_s
  end

  def self.outputFolder
    @output_path.to_s
  end

  # Custom way to run a measure in the test. Overwrites run_measure definition in BTAPMeasureHelper.
  def run_measure(input_arguments, model)
    # Provide feedback as to what is being done to teh terminal.
    puts "Running measure".green
    puts "  with input arguments".green + " #{input_arguments}".light_blue
    puts "  on model with".green + " #{model.modelObjects.count}".light_blue + " objects".green
    puts "  from method".green + " #{caller_locations(1, 1)[0].label.split.last}".light_blue

    # Set the output folder. This should be unique (check done in validateOutputFolder). Create if does not exist.
    output_folder = NRCMeasureTestHelper.outputFolder
    output_folder = NRCMeasureTestHelper.validateOutputFolder(output_folder)
    Dir.mkdir(output_folder) unless Dir.exists?(output_folder)
    # This will create a instance of the measure you wish to test. It does this based on the test class name.
    measure = get_measure_object()
    measure.use_json_package = @use_json_package
    measure.use_string_double = @use_string_double

    # Return false if can't
    return false if false == measure

    # Now get the arguments and create a runner
    arguments = measure.arguments()
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

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
    measure.run(model, runner, argument_map)
    runner.result
    # Reset the output path to the root folder.
    NRCMeasureTestHelper.resetOutputFolder

    return runner
  end

  # Method to report case being tested
  def reportCase(test_name, input_arguments)

    measure = get_measure_object()
    measure_name = measure.name
    measure_name = measure_name.gsub("_", " ").upcase

    #test_dir = Dir.pwd
    out_file = File.new("README.html", "a")
    # readme_out_path = File.join(test_dir, out_file)

    test_name = test_name.gsub("_", " ")

    # To prevent the html from adding the title each time a test is called.
    !$title_bool ? title = " " : title = "Summary Of Test Cases for '#{measure_name}' Measure"

    out_file.puts("<h3 style='color:Blue'><i>#{title}<i></h3>")
    out_file.puts("<h4 style='color:DodgerBlue;'><i>#{$num}- #{test_name}<i></h4>")
    out_file.puts("<table border=3>")
    out_file.puts("<tr>")
    out_file.puts("<th style='background-color:rgb(200, 200, 200);'>Test Argument</th>")
    out_file.puts("<th style='background-color:rgb(200, 200, 200);'>Test Value</th>")
    out_file.puts("</tr>")

    input_arguments.each do |key, value|
      out_file.puts("<tr>")
      out_file.puts("<td style='background-color:rgb(240, 240, 240);'>#{key}</td>")
      out_file.puts("<td style='background-color:rgb(240, 240, 240);'>#{value}</td>")
      out_file.puts("</tr>")
    end
    out_file.puts("</table>")
    out_file.puts("<br>")
    out_file.puts("<br>")

    $title_bool = false
    $num += 1
    out_file.close
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
