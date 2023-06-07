# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcSetFenestrationRoofConductanceByNecbClimateZone< OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  #define the arguments that the user will input
  def initialize()
    super()

    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    #Use percentages instead of values
    @use_percentages = false

    #Set to true if debugging measure.
    @debug = false
    #this is the 'do nothing value and most arguments should have. '
    @baseline = 0.0


    @measure_interface_detailed = [
      {
        "name" => "necb_template",
        "type" => "Choice",
        "display_name" => "Building vintage",
        "default_value" => "NECB2020",
        "choices" => ["NECB2011", "NECB2015", "NECB2017", "NECB2020", "BTAPPRE1980", "BTAP1980TO2010"],
        "is_required" => true
      },
        {
            "name" => "zone4_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone4 Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.9,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone5_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone5 Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.8,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone6_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone6 Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.7,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7A_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7A Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.5,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7B_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7B Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.4,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone8_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone8 Fenestration Insulation U-value (W/m^2 K).",
            "default_value" => 1.3,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]
  end

  def name
    return "Set Fenestration (Roof) Conductance By Necb Climate Zone"
  end


  def description
    return "Modifies fenestration (located in roof surfaces) conductances by NECB climate zone."
  end
  
  # human readable description of modeling approach
  def modeler_description
    return "Modifies fenestartion conductances by NECB climate zone. Applies changes to skylights and tubular daylighting devices Minimum OpenStudio 2.8.1."
  end

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    necb_template = arguments['necb_template']
    zone4_u_value = arguments['zone4_u_value']
    zone5_u_value = arguments['zone5_u_value']
    zone6_u_value = arguments['zone6_u_value']
    zone7A_u_value = arguments['zone7A_u_value']
    zone7B_u_value = arguments['zone7B_u_value']
    zone8_u_value = arguments['zone8_u_value']

    # Turn debugging output on/off
    @debug = true

    # Open a channel to log info/warning/error messages
    @msg_log = OpenStudio::StringStreamLogSink.new
    if @debug
      @msg_log.setLogLevel(OpenStudio::Debug)
    else
      @msg_log.setLogLevel(OpenStudio::Info)
    end
    @start_time = Time.new
    @runner = runner
    @runner.registerInfo("-- Starting measure: #{self.class.name.to_s}.")
	
    # Call get_necb_hdd18 from Standards to figure out climate zone.
    standard = Standard.build(necb_template)
    necb_hdd18 = standard.get_necb_hdd18(model)
    @runner.registerInfo("The Weather File NECB hdd is '#{necb_hdd18}'.")

    # Find the climate zone according to the NECB hdds, then find the corresponding r-value of that climate zone.
    if necb_hdd18 < 3000 then
      u_value = zone4_u_value
    elsif (necb_hdd18 >= 3000 && necb_hdd18 < 4000) then
      u_value = zone5_u_value
    elsif (necb_hdd18 >= 4000 && necb_hdd18 < 5000) then
      u_value = zone6_u_value
    elsif (necb_hdd18 >= 5000 && necb_hdd18 < 6000) then
      u_value = zone7A_u_value
    elsif (necb_hdd18 >= 6000 && necb_hdd18 < 7000) then
      u_value = zone7B_u_value
    elsif (necb_hdd18 >= 7000) then
      u_value = zone8_u_value
    else
      @runner.registerError("Couldn't find a climate zone.")
    end

    #use the built-in error checking
    if not @runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    return false if false == arguments

    #loop through sub surfaces
    @runner.registerInfo("Looping through all surfaces and sub surfaces.")
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      @runner.registerInfo("Checking sub surface: #{sub_surface.name} with boundary condition: #{sub_surface.outsideBoundaryCondition} of type: #{sub_surface.subSurfaceType}.")
      puts "Checking sub surface: #{sub_surface.name} with boundary condition: #{sub_surface.outsideBoundaryCondition} of type: #{sub_surface.subSurfaceType}.".yellow
      if sub_surface.outsideBoundaryCondition == "Outdoors" and (sub_surface.subSurfaceType == "Skylight" || sub_surface.subSurfaceType == "TubularDaylightDiffuser" || sub_surface.subSurfaceType == "TubularDaylightDome")
        surface_conductance = BTAP::Geometry::Surfaces.get_surface_construction_conductance(sub_surface)
		puts "Current conductance: #{surface_conductance}".green
        
		# Set the construction according to the new conductance. Using the method in the Standard class but over-riding the U-value.
        standard.apply_changes_to_surface_construction(model,
                                                           sub_surface,
                                                           u_value,
                                                           nil,
                                                           nil,
                                                           false)

        surface_conductance2 = BTAP::Geometry::Surfaces.get_surface_construction_conductance(sub_surface)
		puts "New conductance: #{surface_conductance2}".pink
        u_value_rounded = sprintf "%.3f", u_value
        surface_conductance2_rounded = sprintf "%.3f", surface_conductance2
        @runner.registerInfo("Initial conductance for #{sub_surface.subSurfaceType} was : #{surface_conductance} , now it has been changed to #{surface_conductance2} ")
        raise("U values for #{surface.surfaceType} was supposed to change to #{u_value_rounded}, but it is #{surface_conductance2_rounded}") if u_value_rounded != surface_conductance2_rounded
      end
    end
    @runner.registerInfo("Looping through all surfaces and sub surfaces...DONE.")
    @runner.registerInfo("-- Finished measure -------------------")
	
	# Do something with the messages.
    log_msgs
	
    return true
  end #end the run method
  
  # Get all the log messages and put into output
  # for users to see.
  def log_msgs
    @msg_log.logMessages.each do |msg|
      # DLM: you can filter on log channel here for now
      if /openstudio.*/.match(msg.logChannel) #/openstudio\.model\..*/
        # Skip certain messages that are irrelevant/misleading
        next if msg.logMessage.include?("Skipping layer") || # Annoying/bogus "Skipping layer" warnings
            msg.logChannel.include?("runmanager") || # RunManager messages
            msg.logChannel.include?("setFileExtension") || # .ddy extension unexpected
            msg.logChannel.include?("Translator") || # Forward translator and geometry translator
            msg.logMessage.include?("UseWeatherFile") # 'UseWeatherFile' is not yet a supported option for YearDescription

        # Report the message in the correct way
        if msg.logLevel == OpenStudio::Info
          @runner.registerInfo(msg.logMessage)
        elsif msg.logLevel == OpenStudio::Warn
          @runner.registerWarning("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Error
          @runner.registerError("[#{msg.logChannel}] #{msg.logMessage}")
        elsif msg.logLevel == OpenStudio::Debug && @debug
          @runner.registerInfo("DEBUG - #{msg.logMessage}")
        end
      end
    end
    @runner.registerInfo("Total Time = #{(Time.new - @start_time).round}sec.")
  end
end #end the measure

#this allows the measure to be used by the application
NrcSetFenestrationRoofConductanceByNecbClimateZone.new.registerWithApplication
