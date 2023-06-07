# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcSetRoofConductanceByNecbClimateZone < OpenStudio::Measure::ModelMeasure
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
            "display_name" => "NECB Zone4 Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.164,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone5_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone5 Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.156,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone6_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone6 Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.138,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7A_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7A Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.121,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone7B_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone7B Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.117,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        },
        {
            "name" => "zone8_u_value",
            "type" => "Double",
            "display_name" => "NECB Zone8 Roof Insulation U-value (W/m^2 K).",
            "default_value" => 0.110,
            "max_double_value" => 5.0,
            "min_double_value" => 0.0,
            "is_required" => true
        }
    ]
    puts "#{@measure_interface_detailed}".yellow

 end

  def name
    return "NrcSetRoofConductanceByNecbClimateZone"
  end


  def description
    return "Modifies roof conductances by NECB climate zone."
  end
  
  # human readable description of modeling approach
  def modeler_description
    return "Modifies roof conductances by NECB climate zone. Minimum OpenStudio 2.8.1; NRCan branch of standards (October 2019)."
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

    # call get_necb_hdd18 from Standards
    standard = Standard.build(necb_template)
    necb_hdd18 = standard.get_necb_hdd18(model)
    runner.registerInfo("The Weather File NECB hdd is '#{necb_hdd18}'.")

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
      runner.registerInfo("Couldn't find a climate zone.")
    end

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    return false if false == arguments

    #Find all roofs and set the construction U_value
    surfaces = model.getSurfaces
    surfaces.each do |surface|
      if surface.outsideBoundaryCondition == "Outdoors" and surface.surfaceType == "RoofCeiling"
        surface_conductance = BTAP::Geometry::Surfaces.get_surface_construction_conductance(surface)
        #set the construction according to the new conductance
        Standard.new.apply_changes_to_surface_construction(model,
                                                           surface,
                                                           u_value,
                                                           nil,
                                                           nil,
                                                           false)

        surface_conductance2 = BTAP::Geometry::Surfaces.get_surface_construction_conductance(surface)
        u_value_rounded = sprintf "%.3f", u_value
        surface_conductance2_rounded = sprintf "%.3f", surface_conductance2
        runner.registerInfo("Initial conductance for #{surface.surfaceType} was : #{surface_conductance} , now it has been changed to #{surface_conductance2} ")
        raise("U values for #{surface.surfaceType} was supposed to change to #{u_value_rounded}, but it is #{surface_conductance2_rounded}") if u_value_rounded != surface_conductance2_rounded
      end
    end
    return true
  end #end the run method
end #end the measure

#this allows the measure to be used by the application
NrcSetRoofConductanceByNecbClimateZone.new.registerWithApplication
