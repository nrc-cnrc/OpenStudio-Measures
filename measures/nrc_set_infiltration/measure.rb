# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
# start the measure
class NrcSetInfiltration < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # Human readable name.
  def name
    return 'Set Infiltration Rate'
  end

  # Human readable description.
  def description
    return 'This measures allows setting the infiltration to a specific value at a given reference pressure. The flow rate is 
       converted to the flow at 5 Pa for above grade surfaces as per the assumption in the NECB.'
  end

  # Human readable description of modeling approach.
  def modeler_description
    return 'The measure sets space infiltration according to PCF 1414, section 8.4.2.9(2), page 7
            Infiltration_5Pa = C × I_75Pa × (S/A)
            Infiltration_5Pa : Air leakage rate of the building envelope at 5 Pa, in L/(s·m2)
            C = (5 Pa / 75 Pa)n , where n = flow exponent
            I_75Pa : Normalized air leakage rate at 75 Pa, in L/(s·m2)
            S = total area of the building envelope (the lowest floor area + below-ground and above-ground walls area + roof area (including
                vertical fenestration and skylights) , in m2
            A = total area of above-grade walls, in m2
            To neglect the surface area adjustment enter two identical numers for above grage and total surface area.'
  end

  # Define the outputs that the measure will create. 
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new
    outs << OpenStudio::Measure::OSOutput.makeDoubleOutput('calculated_infiltration_rate') # rate at 5Pa L/s/m2; 4 significant figs
    return outs
  end

  # Use the constructor to set global variables.
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    @measure_interface_detailed = [
      {
        "name" => "flow_rate",
        "type" => "Double",
        "display_name" => 'Space Infiltration Flow per Exterior Envelope Surface Area L/s/m2 at reference pressure',
        "default_value" => 4.2,
        "max_double_value" => 30.0,
        "min_double_value" => 0.05,
        "is_required" => true
      },
      {
        "name" => "reference_pressure",
        "type" => "Double",
        "display_name" => 'Reference pressure',
        "default_value" => 75, # default; NECB 2020
        "max_double_value" => 100.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "flow_exponent",
        "type" => "Double",
        "display_name" => 'Flow exponent',
        "default_value" => 0.60, # default; NECB 2020
        "max_double_value" => 1.0,
        "min_double_value" => 0.4,
        "is_required" => true
      },
      {
        "name" => "total_surface_area",
        "type" => "Double",
        "display_name" => 'Total surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "max_double_value" => 10000000.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "above_grade_wall_surface_area",
        "type" => "Double",
        "display_name" => 'Above grade wall surface area (m2), please type 0.0 to use value from model',
        "default_value" => 0.0,
        "max_double_value" => 10000000.0,
        "min_double_value" => 0.0,
        "is_required" => true
      }
    ]
  end

  # Define what happens when the measure is run.
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    #   ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    flow_rate_at_ref = arguments['flow_rate']
    ref_pressure = arguments['reference_pressure']
    flow_exponent = arguments['flow_exponent']
    total_surface_area = arguments['total_surface_area']
    above_grade_wall_surface_area = arguments['above_grade_wall_surface_area']

    flow_rate_at_ref = flow_rate_at_ref / 1000.0 # convert from  L/(s·m2)  to m3/(s·m2)

    # Calculate total area of above and below grade envelope area.
    totalAreaBuildingEnvelope = 0.0
    totalAboveGradeArea = 0.0

    model.getSpaces.each do |space|
      multiplier = space.multiplier
      space.surfaces.each do |surface|
        if surface.outsideBoundaryCondition == "Outdoors" then
          area = surface.grossArea * multiplier
          totalAreaBuildingEnvelope += area
          totalAboveGradeArea += area
        elsif surface.outsideBoundaryCondition == "Ground" then
          area = surface.grossArea * multiplier
          totalAreaBuildingEnvelope += area
        end
      end
    end

    if total_surface_area < 0.01 # If the user selects zero, then use total envelope area of the model.
      total_surface_area = totalAreaBuildingEnvelope
    end

    if above_grade_wall_surface_area < 0.01 # If the user selects zero, then use above grade area of the model.
      above_grade_wall_surface_area = totalAboveGradeArea
    end

    # Convert the flow_rate provided to the one at 5 Pa delta P (as per NECB assumptions).
    infiltration_5Pa = flow_rate_at_ref * ((5.0 / ref_pressure) ** (flow_exponent)) * total_surface_area / above_grade_wall_surface_area
    runner.registerValue('calculated_infiltration_rate', (infiltration_5Pa).signif(4), 'm3/s/m2')

    puts "Infiltration flow @5Pa #{infiltration_5Pa.round(6)}; above grade area #{above_grade_wall_surface_area.round(2)}; total surface area #{total_surface_area.round(2)}".green
    
    # Get space infiltration objects used in the model.
    space_infiltration_objects = model.getSpaceInfiltrationDesignFlowRates

    #loop through all infiltration objects
    space_infiltration_objects.each do |space_infiltration_object|
      puts "Changing infiltration from #{space_infiltration_object.flowperExteriorSurfaceArea.get.signif(6)} to #{infiltration_5Pa.signif(6)}"
      space_infiltration_object.setFlowperExteriorSurfaceArea(infiltration_5Pa)
    end

    return true
  end
end

# register the measure to be used by the application
NrcSetInfiltration.new.registerWithApplication
