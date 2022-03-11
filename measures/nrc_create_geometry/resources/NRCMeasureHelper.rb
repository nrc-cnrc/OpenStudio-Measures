# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'
require 'erb'
require 'json'

module NRCMeasureHelper
  include BTAPMeasureHelper
end

module NRCMeasureTestHelper

  include BTAPMeasureTestHelper

  # Define the output path. Set defaults and remove any existing outputs.
  @output_root_path = File.expand_path("#{File.expand_path(__dir__)}/../tests/output")
  Dir.mkdir @output_root_path unless Dir.exists?(@output_root_path)
  @output_path = @output_root_path

  # Remove the existing test results. Need to control when this is done as multiple test scripts could be
  #  accessing the same path.
  def self.removeOldOutputs(before: Time.now)
    existing_folders = Dir.entries(@output_path) - ['.', '..'] # Remove current folder above from list before deleting!
    existing_folders.each do |entry|
      folder_to_remove = File.expand_path("#{@output_path}/#{entry}")
      puts "Checking existing output folder: #{folder_to_remove}".green
	  if File.mtime(folder_to_remove) < before
        puts "Removing existing output folder: #{folder_to_remove}".yellow
        FileUtils.rm_rf(folder_to_remove)
	  else
        puts "Skipping existing output folder: #{folder_to_remove}".light_blue
	  end
    end
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

  #
  # Define the folder containing the test file for the test case summary output file.
  @measure_path = File.expand_path("#{File.expand_path(__dir__)}/../tests")
  @test_summary_mdfile = @measure_path + "/" + "README.md"
  FileUtils.rm_rf(@test_summary_mdfile)

  # Create initial file with title.
  @testSummaryTitleRequired = true

  def self.testSummaryTitleRequired
    return @testSummaryTitleRequired
  end

  def self.setTestSummaryTitle(required)
    @testSummaryTitleRequired = required
  end

  def self.testSummaryMDfile
    @test_summary_mdfile.to_s
  end

  # Test count
  @testSummaryCount = 1
   def self.incrementTestSummaryCount
    @testSummaryCount += 1
  end

  def self.testSummaryCount
    return @testSummaryCount
  end

  #
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

    # Run the measure
    measure.run(model, runner, argument_map)
    runner.result

    # Reset the output path to the root folder.
    NRCMeasureTestHelper.resetOutputFolder

    # Add summary of test to README file
    measure_name = measure.name.gsub("_", " ").upcase
    reportCase(measure_name, output_folder.split('/').last, input_arguments)
    return runner
  end

  # Method to report case being tested
  def reportCase(measure_name, test_name, input_arguments)

    # File name defined above. Open for appending.
    out_file = File.new("#{NRCMeasureTestHelper.testSummaryMDfile}", "a")

    # Only add the page title once
    if NRCMeasureTestHelper.testSummaryTitleRequired
      title = "# Summary Of Test Cases for '#{measure_name}' Measure"
      out_file.puts("#{title}")
      out_file.puts(" ")
    end

    # Current test name.
    test_name = test_name.gsub("_", " ")
    out_file.puts("## #{NRCMeasureTestHelper.testSummaryCount} - #{test_name}")

    # Create a table describing the case tested. Table header first.
    out_file.puts("| Test Argument | Test Value |")
    out_file.puts("| ------------- | ---------- |")

    # Table contents.
    input_arguments.each do |key, value|

      if key.include? "json_input"
        # Value is a string, has to be parsed and converted into hash
        value1=JSON.parse(value)
        value1.each do |key, value|
          out_file.puts("| #{key} |#{value} |")
        end
      else
        out_file.puts("| #{key} |#{value} |")
      end
    end
    out_file.puts(" ")
    out_file.close

    # Update logical and counters
    NRCMeasureTestHelper.setTestSummaryTitle(false)
    NRCMeasureTestHelper.incrementTestSummaryCount
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
