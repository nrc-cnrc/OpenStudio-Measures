# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require_relative 'resources/NRCMeasureHelper'

module FindOrientation
  # function to find the orientation of surfaces
  def find_orientation(model, surface)
    absoluteAzimuth = OpenStudio::convert(surface.azimuth, "rad", "deg").get + surface.space.get.directionofRelativeNorth + model.getBuilding.northAxis
    until absoluteAzimuth < 360.0
      absoluteAzimuth = absoluteAzimuth - 360.0
    end
    if (absoluteAzimuth >= 315.0 || absoluteAzimuth < 45.0)
      facade = "N"
    elsif (absoluteAzimuth >= 45.0 && absoluteAzimuth < 135.0)
      facade = "E"
    elsif (absoluteAzimuth >= 135.0 && absoluteAzimuth < 225.0)
      facade = "S"
    elsif (absoluteAzimuth >= 225.0 && absoluteAzimuth < 315.0)
      facade = "W"
    end
    return facade
  end
end

# start the measure
class NrcRenameSurfaces < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)
  include(FindOrientation)

  def name
    # Measure name should be the title case of the class name.
    return 'NrcRenameSurfaces'
  end

  # human readable description
  def description
    return 'New measure to go through a model and update the names of surfaces and sub surfaces based on their connection type and orientation.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Replace surfaces and sub surfaces with new names as follows :
            Walls
            Exterior walls -> ExtWall-Orientation (where Orientation is N, S, E, W)
            Basement walls -> BasementWall-Orientation (where Orientation is N, S, E, W and the wall is below grade)
            Interior walls -> IntWall-OtherZone (where OtherZone is the name of the space on the other side)
            Windows
            Exterior windows -> ExtWindow-Orientation (where Orientation is N, S, E, W)
            Skylights -> ExtSkylight
            Roof/Floors
            Roof -> Roof (horizontal surface connected to the outside)
            Interior Floor -> Floor-OtherZone (where OtherZone is the name of the space on the other side)
            Interior Ceiling -> Ceiling-OtherZone (where OtherZone is the name of the space on the other side)
            Ground floor -> GroundFloor (i.e. the floor surface connected to the ground not a space below)'
  end

  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false
    @measure_interface_detailed = [
        {
            "name" => "rename_all_surfaces",
            "type" => "Bool",
            "display_name" => "Rename all surfaces and sub surfaces of the model.",
            "default_value" => true,
            "is_required" => true
        }
    ]
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
    rename_all_surfaces = arguments['rename_all_surfaces']
    if (rename_all_surfaces)
      new_surface_name = ""
      new_subSurface_name = ""
      subSurface_name=""
      model.getSurfaces.each do |surface|
        name1= (surface.name).to_s
        outsideBoundaryCondition = surface.outsideBoundaryCondition
        if (surface.surfaceType.to_s.include? "Wall")
          new_surface_name = "Wall"
          facade = find_orientation(model, surface)
          if (outsideBoundaryCondition == "Surface")
            next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
            adj_space = surface.adjacentSurface.get.space.get.name.to_s
            new_surface_name = "Int" + new_surface_name + "-" + adj_space
          elsif (outsideBoundaryCondition == "Outdoors")
            new_surface_name = "Ext" + new_surface_name + "-" + facade
          elsif (outsideBoundaryCondition == "Ground")
            new_surface_name = "BasementWall" + "-" + facade
          end

        elsif (surface.surfaceType.to_s.include? "RoofCeiling")
          outsideBoundaryCondition = surface.outsideBoundaryCondition
          if (outsideBoundaryCondition == "Surface")
            next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
            adj_space = surface.adjacentSurface.get.space.get.name.to_s
            new_surface_name = "Ceiling" + "-" + adj_space
          elsif (outsideBoundaryCondition == "Outdoors")
            new_surface_name = "Roof"
          end
        elsif (surface.surfaceType.to_s.include? "Floor")
          if (outsideBoundaryCondition == "Surface")
            next if (surface.adjacentSurface.empty? || surface.adjacentSurface.get.space.empty?)
            adj_space = surface.adjacentSurface.get.space.get.name.to_s
            new_surface_name = "Floor" + "-" + adj_space
          elsif (outsideBoundaryCondition == "Ground")
            new_surface_name = "GroundFloor"
          end
        end

        surface.setName(new_surface_name)
        surface.subSurfaces.each do |subsurf|
          subSurface_name = (subsurf.name).to_s
          if (subsurf.subSurfaceType.to_s.include? "Window")
            facade = find_orientation(model, subsurf)
            new_subSurface_name = "ExtWindow" + "-" + facade
          elsif (subsurf.subSurfaceType.to_s.include? "Skylight")
            new_subSurface_name = "ExtSkylight"
          end
          subsurf.setName(new_subSurface_name)
        end
        runner.registerInfo("Surface '#{name1}' is renamed to : #{new_surface_name}".blue)
        runner.registerInfo("Sub surface '#{subSurface_name}' is renamed to : #{new_subSurface_name}".light_blue)
      end

    else # if the user selected false as the measure argument
      runner.registerInfo("You have selected 'false', so the measure won't change the names of any surfaces. Please select 'true' to change the surfaces' names.")
    end
    return true
  end
end

# register the measure to be used by the application
NrcRenameSurfaces.new.registerWithApplication
