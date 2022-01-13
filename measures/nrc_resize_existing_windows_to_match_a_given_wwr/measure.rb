# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'
require 'openstudio-standards'

# start the measure
class NrcResizeExistingWindowsToMatchAGivenWWR < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  # human readable name
  def name
    return NrcResizeExistingWindowsToMatchAGivenWWR
  end

  # human readable description
  def description
    return "This measure aims to resize all of the existing windows in order to produce a specified, user-input, window to wall ratio.
The windows will be resized around their centroid.
It should be noted that this measure should work in all cases when DOWNSIZING the windows (which is often the need given the 40% WWR imposed as baseline by ASHRAE Appendix G).
If you aim to increase the area, please note that this could result in subsurfaces being larger than their parent surface"
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure is measure was retrieved from - https://bcl.nrel.gov/ (original author Julien Marrec ) and was modified by the NRC.
NRC modifications : cz_#_fdwr variables,remove_skylight variable,  set checkwall variable to default 'false', check model climate zone file before placing cz_#fdwr into variable 'wwr_after', loop to remove skylights
Added test.rb
The measure works in several steps:

1. Find the current Window to Wall Ratio (WWR).
This will compute the WWR by taking into account all of the surfaces that have all of the following characteristics:
- They are walls
- They have the outside boundary condition as 'Outdoors' (aims to not take into account the adiabatic surfaces)
- They are SunExposed (could be removed...)

2. Resize all of the existing windows by re-setting the vertices: scaled centered on centroid.
"
  end

  #Use the constructor to set global variables
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
        "name" => "remove_skylight",
        "type" => "Bool",
        "display_name" => "Remove skylights?",
        "default_value" => false,
        "is_required" => true
      },
      {
        "name" => "cz_4_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 4 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_5_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 5 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_6_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 6 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7A_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7A FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_7B_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 7B FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "cz_8_fdwr",
        "type" => "Double",
        "display_name" => "Climate zone 8 FDWR",
        "default_value" => 0.2,
        "is_required" => true
      },
      {
        "name" => "check_wall",
        "type" => "Bool",
        "display_name" => "Only affect surfaces that are 'walls'?",
        "default_value" => false,
        "is_required" => false
      },
      {
        "name" => "check_outdoors",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that have boundary condition = "Outdoor"?',
        "default_value" => true,
        "is_required" => false
      },
      {
        "name" => "check_sunexposed",
        "type" => "Bool",
        "display_name" => 'Only affect surfaces that are "SunExposed"?',
        "default_value" => true,
        "is_required" => false
      }
    ]
  end

  def getExteriorWindowToWallRatio(spaceArray)

    # counters
    total_gross_ext_wall_area = 0
    total_ext_window_area = 0

    spaceArray.each do |space|

      #get surface area adjusting for zone multiplier
      zone = space.thermalZone
      if not zone.empty?
        zone_multiplier = zone.get.multiplier
        if zone_multiplier > 1
        end
      else
        zone_multiplier = 1 #space is not in a thermal zone
      end

      space.surfaces.each do |s|
        next if not s.surfaceType == "Wall"
        next if not s.outsideBoundaryCondition == "Outdoors"
        # Surface has to be Sun Exposed!
        next if not s.sunExposure == "SunExposed"

       surface_gross_area = s.grossArea * zone_multiplier

        #loop through sub surfaces and add area including multiplier
        ext_window_area = 0
        s.subSurfaces.each do |subSurface|
          ext_window_area = ext_window_area + subSurface.grossArea * subSurface.multiplier * zone_multiplier
        end

        total_gross_ext_wall_area += surface_gross_area
        total_ext_window_area += ext_window_area
      end #end of surfaces.each do
    end # end of space.each do
    result = total_ext_window_area / total_gross_ext_wall_area
    return result

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables that can be accessed across the measure
    remove_skylight = arguments['remove_skylight']
    cz_4_fdwr = arguments['cz_4_fdwr']
    cz_5_fdwr = arguments['cz_5_fdwr']
    cz_6_fdwr = arguments['cz_6_fdwr']
    cz_7A_fdwr = arguments['cz_7A_fdwr']
    cz_7B_fdwr = arguments['cz_7B_fdwr']
    cz_8_fdwr = arguments['cz_8_fdwr']
    check_wall = arguments['check_wall']
    check_outdoors = arguments['check_outdoors']
    check_sunexposed = arguments['check_sunexposed']

    #assign the user inputs to variables
    #Need to determine which climate zone the model is in, before allocating the correct FDWR
    # call get_necb_hdd18 from Standards
    necb_template = "NECB2017"
    standard = Standard.build(necb_template)
    model_hdd = standard.get_necb_hdd18(model)

    model_cz = 'error'
    if model_hdd < 3000 then
      wwr_after = cz_4_fdwr
    elsif (model_hdd >= 3000 && model_hdd < 4000) then
      wwr_after = cz_5_fdwr
    elsif (model_hdd >= 4000 && model_hdd < 5000) then
      wwr_after = cz_6_fdwr
    elsif (model_hdd >= 5000 && model_hdd < 6000) then
      wwr_after = cz_7A_fdwr
    elsif (model_hdd >= 6000 && model_hdd < 7000) then
      wwr_after = cz_7B_fdwr
    elsif (model_hdd >= 7000) then
      wwr_after = cz_8_fdwr
    else
      runner.registerError("Couldn't find a climate zone to allocate FDWR")
    end
    #check reasonableness of fraction
    if wwr_after <= 0 or wwr_after >= 1
      runner.registerError("Window to Wall Ratio must be greater than 0 and less than 1.")
      return false
    end

    wwr_before = getExteriorWindowToWallRatio(model.getSpaces)

     # report initial condition of model
    runner.registerInitialCondition("The initial WWR was".green + " #{OpenStudio::toNeatString(wwr_before * 100, 2, true)}%.".light_blue)

    area_scale_factor = wwr_after / wwr_before
    scale_factor = area_scale_factor ** 0.5

    #Remove skylights
    if remove_skylight
      skylights = model.getSubSurfaces.select { |subsurface| subsurface.subSurfaceType == 'Skylight' || subsurface.tilt < 1.047197551 } # Skylight subsurfaces or tilt less than 60deg
      skylights.each do |skylight|
        runner.registerInfo("skylight - #{skylight.name} will be removed")
      end
      model.getSubSurfaces.select { |subsurface| subsurface.subSurfaceType == 'Skylight' || subsurface.tilt < 1.047197551 }.each(&:remove)
    end

    # Loop on surfaces
    surfaces = model.getSurfaces

    counter = 0

    runner.registerInfo("Click on 'Advanced' for a CSV of each surface WWR before and after".green)
    puts "\n=====================================================\n".green
    puts "RESIZING INFORMATION (CSV)".green
    puts "Surface Name, WWR_before, WWR_after".green

    surfaces.each do |surface|
      next if (not surface.surfaceType == "Wall") & check_wall
      next if (not surface.outsideBoundaryCondition == "Outdoors") & check_outdoors
      # Surface has to be Sun Exposed!
      next if (not surface.sunExposure == "SunExposed") & check_sunexposed
      next if surface.subSurfaces.empty?

      counter += 1
      # Write before
      print "#{surface.name.to_s}".light_blue + ",".green + "#{surface.windowToWallRatio.to_s}".light_blue

      # Loop on each subSurfaces
      surface.subSurfaces.each do |subsurface|
        # Get the centroid
        g = subsurface.centroid

        # Create an array to collect the new vertices (subsurface.vertices is a frozen array)
        vertices = []

        # Loop on vertices
        subsurface.vertices.each do |vertex|
          # A vertex is a Point3d.
          # A diff a 2 Point3d creates a Vector3d

          # Vector from centroid to vertex (GA, GB, GC, etc)
          centroid_vector = vertex - g

          # Resize the vector (done in place) according to scale_factor
          centroid_vector.setLength(centroid_vector.length * scale_factor)

          # Change the vertex
          vertex = g + centroid_vector
          vertices << vertex
        end # end of loop on vertices
        # Assign the new vertices to the subsurface
        subsurface.setVertices(vertices)
      end # End of loop on subsurfaces
      # Append the new windowToWallRatio
      print ",".green + "#{surface.windowToWallRatio.to_s}".light_blue + "\n"
    end # end of surfaces.each do |surface|

    # report final condition of model
    check_wwr_after = getExteriorWindowToWallRatio(model.getSpaces)
    runner.registerFinalCondition("Checking final WWR".green + " #{OpenStudio::toNeatString(check_wwr_after * 100, 2, true)}%".light_blue+ ".".green + "#{counter}".light_blue + " surfaces were resized".green)
    return true
  end
end

# register the measure to be used by the application
NrcResizeExistingWindowsToMatchAGivenWWR.new.registerWithApplication
