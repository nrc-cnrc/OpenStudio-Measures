# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcSetFenestrationWallConductanceByNecbClimateZone < OpenStudio::Measure::ModelMeasure
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
    return "Set Fenestration (Wall) Conductance By Necb Climate Zone"
  end

  def description
    return "Modifies fenestration (located in walls) conductances by NECB climate zone."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Modifies fenestration conductances by NECB climate zone. Applies to fixed and operable windows. Minimum OpenStudio 2.8.1."
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
      runner.registerError("Couldn't find a climate zone.".red)
    end

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    return false if false == arguments

    #loop through sub surfaces
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      if sub_surface.outsideBoundaryCondition == "Outdoors" and (sub_surface.subSurfaceType == "FixedWindow" || sub_surface.subSurfaceType == "OperableWindow")
        surface_conductance = BTAP::Geometry::Surfaces.get_surface_construction_conductance(sub_surface)
        #set the construction according to the new conductance

        Standard.new.apply_changes_to_surface_construction(model,
                                                           sub_surface,
                                                           u_value,
                                                           nil,
                                                           nil,
                                                           false)

        surface_conductance2 = BTAP::Geometry::Surfaces.get_surface_construction_conductance(sub_surface)
        u_value_rounded = sprintf "%.3f", u_value
        surface_conductance2_rounded = sprintf "%.3f", surface_conductance2
        runner.registerInfo("Initial conductance for".green + " #{sub_surface.subSurfaceType}".light_blue + " was :".green + " #{surface_conductance}".light_blue + " , now it has been changed to".green + " #{surface_conductance2} ".light_blue)
        raise("U values for #{surface.surfaceType} was supposed to change to #{u_value_rounded}, but it is #{surface_conductance2_rounded}".red) if u_value_rounded != surface_conductance2_rounded
      end
    end
    return true
  end
end

#this allows the measure to be used by the application
NrcSetFenestrationWallConductanceByNecbClimateZone.new.registerWithApplication
