require 'fileutils'
require 'parallel'
require 'open3'
require 'minitest/autorun'
require 'json'
require 'ruby-progressbar'

# Set file containing list of measures to test.
TestListFile = File.join(File.dirname(__FILE__), 'measures_to_test.txt')

# Set number of processors to use on the host computer.
ProcessorsUsed = (Parallel.processor_count.to_f * 2/3).ceil

# Hash of test results
Summary_output = Hash.new()

# Array of measure folders
All_measures = Dir['../measures/*']

# Define colours for output.
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  # Use for error messages
  def red
    colorize(31)
  end

  # Use for success messages
  def green
    colorize(32)
  end

  # Use for warning messages
  def yellow
    colorize(33)
  end

  # Use for start of tests/sections
  def blue
    colorize(34)
  end

  # Use for argument value reporting
  def light_blue
    colorize(36)
  end
  
  # Use for larger text dumps (e.g. whole files)
  def pink
    colorize(35)
  end
end

class RunAllTests < Minitest::Test
  def test_all()
	test_file_list = []
    if File.exist?(TestListFile)
      puts "Reading measures to test from #{TestListFile}".green
      # load test files from file.
      full_file_list = File.readlines(TestListFile)
      # Select only .rb files that exist
	  full_file_list.each do |item|
        potential_test = File.expand_path("../#{item}", File.dirname(__FILE__))
	    test_file_list << potential_test if File.exist?(File.absolute_path("#{potential_test.strip}"))
      end
    else
      puts "Could not find list of measures to test at #{TestListFile}".red
      return false
    end
    msg="Some tests failed. Please ensure all test pass and tests have been updated to reflect the changes you expect before issuing a pull request."
    assert(ParallelTests.new.run(test_file_list), msg.red)
  end
end

def write_results(result, test_file)
  test_file_output = File.dirname(test_file.strip) + "/" + File.basename(test_file.strip, ".rb") + "-output.json"
  File.delete(test_file_output) if File.exist?(test_file_output)
  test_result = false
  if result[2].success?
    puts "PASSED: #{test_file.strip}".green
	Summary_output[test_file.to_s]['result'] = "PASSED"
    return true
  else
    #store output for failed run.
    output = {"test" => test_file,
              "test_result" => test_result,
              "output" => {
                  "status" => result[2],
                  "std_out" => result[0].split(/\r?\n/),
                  "std_err" => result[1].split(/\r?\n/)
              }
    }

    #puts test_file_output
    File.open(test_file_output, 'w') {|f| f.write(JSON.pretty_generate(output))}
    puts "FAILED: #{test_file}".red
    puts "--------------- Full traceback ---------------"
    puts output.to_s.pink
    puts "--------------- Error text (from above) ---------------"
    error_messages = result[0].split(/\r?\n/).select{|e| e.match?/"RuntimeError"|"Errno"/}.to_s
    puts error_messages.red
    puts "---------------"
	Summary_output[test_file.to_s]['result'] = "FAILED"
	Summary_output[test_file.to_s]['errors'] = error_messages
    return false
  end
end

class ParallelTests
  def run(file_list)
    fail_count = 0
    completed = []

    full_file_list = nil

    # Shuffle the order of the supplied test files (these are absolute paths to the test.rb file)
    full_file_list = file_list.shuffle

    # Run the tests in parallel using the available resources.
    puts "Running #{full_file_list.size} test suites in parallel using #{ProcessorsUsed} of available cpus."
	overall_start_time = Time.now
    puts "Time: #{overall_start_time}".yellow
    Parallel.each(full_file_list, in_threads: (ProcessorsUsed), progress: "Progress:") do |test_file|
      t_start = Time.now
      puts "STARTING:: Worker: #{Parallel.worker_number}, Time: #{t_start.strftime("%k:%M:%S")}, File: #{test_file.strip}".blue
      Summary_output[test_file.to_s] = {}
	  Summary_output[test_file.to_s]['start'] = t_start.to_i
      FileUtils.rm_rf(File.join( test_file, "_test_output.json"))
	  
	  # Pass the overall start time to the test scripts for identifying old test output (really important where there are
	  #  multiple test scripts for one measure (e.g. create grometry).
      test_passed = write_results(Open3.capture3('bundle', 'exec', 'ruby', "#{test_file.strip}", "#{overall_start_time.to_i}"), test_file)
	  fail_count = fail_count + 1 unless test_passed
      puts "FINISHED:: Worker: #{Parallel.worker_number}, Time: #{Time.now.strftime("%k:%M:%S")}, Duration: #{(Time.now - t_start).to_i} s, File: #{test_file.strip}".light_blue
      Summary_output[test_file.to_s]['end'] = Time.now.to_i
      Summary_output[test_file.to_s]['duration'] = Summary_output[test_file.to_s]['end'] - Summary_output[test_file.to_s]['start']
      completed << test_file.to_s

      # If long running list what we have left to complete
      elapsed_time = Time.now.to_i-overall_start_time.to_i
      if (elapsed_time > 500) then
        puts "Overall running time of #{elapsed_time} seconds so far".yellow
        puts "Remaining tests:".yellow
        (full_file_list - completed).each do |test_name|
          puts "#{test_name}".gsub(/(\r$|\n$)/,'').yellow
        end
      end
    end

	# Report testing summary
    puts "Testing summary"
    puts "  Timings"
    #Summary_output.each do |key, value|
	Summary_output.sort_by { |_, value| value['duration'] }.each do |key, value|
	  start = Time.at(value['start'])
	  finish = Time.at(value['end'])
	  puts "Duration: #{value['duration']}s (Start: #{start.strftime("%k:%M:%S")}, Finish: #{finish.strftime("%k:%M:%S")}); Test:#{key}"
    end
	
	# Report if any missing tests
    puts "  Measures not included"
	All_measures.each do |measure|
	  measure_name = measure.gsub('../measures/','')
	  puts "Did not test measure #{measure_name}".red unless Summary_output.keys.any?{|s| s.include?(measure_name)}
	end
	
	# Which tests passed/failed.
    puts "  Pass/Fail summary"
    Summary_output.each do |key, value|
      if value['result'] == "PASSED"
		puts "PASSED: #{key.strip}".green
      else
		puts "FAILED: #{key.strip}".red
		puts "Reason: #{value['errors']}".red
      end
    end
	
	# Report overall elapsed time.
    minutes, seconds = (Time.now.to_i-overall_start_time.to_i).divmod(60)
	puts "Overall elapsed time for tests #{minutes}m #{seconds}s".yellow

	# Return with correct state.
	if fail_count > 0 then
      puts "#{fail_count} tests failed!".red
	  return false
	else
      return true
	end
	
  end
end
