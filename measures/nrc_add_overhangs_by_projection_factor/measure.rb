require_relative 'resources/NRCMeasureHelper'

# start the measure
class NrcAddOverhangsByProjectionFactor < OpenStudio::Measure::ModelMeasure
  attr_accessor :use_json_package, :use_string_double
  include(NRCMeasureHelper)

  # define the name that a user will see
  def name
    return 'NrcAddOverhangsByProjectionFactor'
  end

  # human readable description
  def description
    return 'Add overhangs by projection factor to specified windows. The projection factor is the overhang depth divided by the window height. This can be applied to windows by the closest cardinal direction. If baseline model contains overhangs made by this measure, they will be replaced. Optionally the measure can delete any pre-existing space shading surfaces.'
  end

  # human readable description of modeling approach
  def modeler_description
    return "This measure was obtained from https://bcl.nrel.gov/. The measure arguments have been updated to use 'NRCMeasureHelper', and also the test.rb has been updated.
    If requested then delete existing space shading surfaces. Then loop through exterior windows. If the requested cardinal direction is the closest to the window, then add the overhang. Name the shading surface the same as the window but append with '-Overhang'.  If a space shading surface of that name already exists, then delete it before making the new one. This measure has no life cycle cost arguments. You can see the economic impact of the measure by costing the construction used for the overhangs."
  end

  #define the arguments that the user will input
  def initialize()
    super()
    #Set to true if you want to package the arguments as json.
    @use_json_package = false
    #Set to true if you want to want to allow strings and doubles in stringdouble types. Set to false to force to use doubles. The latter is used for certain
    # continuous optimization algorithms. You may have to re-examine your input in PAT as this fundamentally changes the measure.
    @use_string_double = false

    @measure_interface_detailed = [
      {
        "name" => "facade",
        "type" => "Choice",
        "display_name" => "Cardinal Direction",
        "default_value" => "South",
        "choices" => ["North", "East", "South", "West"],
        "is_required" => true
      },
      {
        "name" => "projection_factor",
        "type" => "Double",
        "display_name" => "Projection Factor.",
        "default_value" => 0.5,
        "max_double_value" => 1.0,
        "min_double_value" => 0.0,
        "is_required" => true
      },
      {
        "name" => "remove_ext_space_shading",
        "type" => "Bool",
        "display_name" => "Remove Existing Space Shading Surfaces From the Model.",
        "default_value" => false,
        "is_required" => true
      }
    ]
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # Gets arguments from interfaced and puts them in a hash with there display name. This also does a check on ranges to
    # ensure that the values inputted are valid based on your @measure_interface array of hashes.
    arguments = validate_and_get_arguments_in_hash(model, runner, user_arguments)

    #puts JSON.pretty_generate(arguments)
    return false if false == arguments

    # Assign the user inputs to variables
    projection_factor = arguments['projection_factor']
    facade = arguments['facade']
    remove_ext_space_shading = arguments['remove_ext_space_shading']

    # check reasonableness of fraction
    projection_factor_too_small = false
    if projection_factor < 0
      runner.registerError('Please enter a positive number for the projection factor.')
      return false
    elsif projection_factor < 0.1
      runner.registerWarning("The requested projection factor of #{projection_factor} seems unusually small, no overhangs will be added.")
      projection_factor_too_small = true
    elsif projection_factor > 5
      runner.registerWarning("The requested projection factor of #{projection_factor} seems unusually large.")
    end

    # Helper that loops through lifecycle costs getting total costs under "Construction" or "Salvage" category and add to counter if occurs during year 0
    def get_total_costs_for_objects(objects)
      counter = 0
      objects.each do |object|
        object_LCCs = object.lifeCycleCosts
        object_LCCs.each do |object_LCC|
          if (object_LCC.category == 'Construction') || (object_LCC.category == 'Salvage')
            if object_LCC.yearsFromStart == 0
              counter += object_LCC.totalCost
            end
          end
        end
      end
      return counter
    end

    # Counter for year 0 capital costs
    yr0_capital_totalCosts = 0

    # Get initial construction costs and multiply by -1
    yr0_capital_totalCosts += get_total_costs_for_objects(model.getConstructions) * -1

    # Reporting initial condition of model
    number_of_exist_space_shading_surf = 0
    shading_groups = model.getShadingSurfaceGroups
    shading_groups.each do |shading_group|
      if shading_group.shadingSurfaceType == 'Space'
        number_of_exist_space_shading_surf += shading_group.shadingSurfaces.size
      end
    end
    runner.registerInitialCondition("The initial building had".green + " #{number_of_exist_space_shading_surf}".light_blue + " space shading surfaces.".green)
    # delete all space shading groups if requested
    if remove_ext_space_shading && (number_of_exist_space_shading_surf > 0)
      num_removed = 0
      shading_groups.each do |shading_group|
        if shading_group.shadingSurfaceType == 'Space'
          shading_group.remove
          num_removed += 1
        end
      end
      runner.registerInfo("Removed all".green + " #{num_removed}".light_blue + " space shading surface groups from the model.".green)
    end

    # Flag for not applicable
    overhang_added = false

    # Loop through surfaces finding exterior walls with proper orientation
    sub_surfaces = model.getSubSurfaces
    sub_surfaces.each do |sub_surface|
      next if sub_surface.outsideBoundaryCondition != 'Outdoors'
      if sub_surface.name.to_s.include? "Window"
        azimuth = OpenStudio::Quantity.new(sub_surface.azimuth, OpenStudio.createSIAngle)
        azimuth = OpenStudio.convert(azimuth, OpenStudio.createIPAngle).get.value

        if facade == 'North'
          next if !((azimuth >= 315.0) || (azimuth < 45.0))
        elsif facade == 'East'
          next if !((azimuth >= 45.0) && (azimuth < 135.0))
        elsif facade == 'South'
          next if !((azimuth >= 135.0) && (azimuth < 225.0))
        elsif facade == 'West'
          next if !((azimuth >= 225.0) && (azimuth < 315.0))
        else
          runner.registerError('Unexpected value of facade: ' + facade + '.'.red).
            return false
        end

        # Delete existing overhang for this window if it exists from previously run measure
        shading_groups.each do |shading_group|
          shading_s = shading_group.shadingSurfaces
          shading_s.each do |shading_surface|
            if shading_surface.name.to_s == "#{sub_surface.name} - Overhang"
              shading_surface.remove
              runner.registerWarning("Removed pre-existing window shade named '#{shading_surface.name}'.".yellow)
            end
          end
        end

        if projection_factor_too_small
          # new overhang would be too small and would cause errors in OpenStudio
          # don't actually add it, but from the measure's perspective this worked as requested
          overhang_added = true
        else
          # add the overhang
          new_overhang = sub_surface.addOverhangByProjectionFactor(projection_factor, 0)
          if new_overhang.empty?
            ok = runner.registerWarning('Unable to add overhang to ' + sub_surface.briefDescription +
                                          ' with projection factor ' + projection_factor.to_s + ' and offset ' + offset.to_s + '.'.yellow)
            return false if !ok
          else
            new_overhang.get.setName("#{sub_surface.name} - Overhang")
            runner.registerInfo("Added overhang ".green + "#{new_overhang.get.briefDescription}".light_blue + " to ".green +
                                  "#{sub_surface.briefDescription}".light_blue + " with projection factor ".green + "#{projection_factor.to_s}".light_blue +
                                  " and offset ".green + '0'.light_blue + '.'.green)

            overhang_added = true
          end
        end
      end
    end

    if !overhang_added
      runner.registerAsNotApplicable("The model has exterior #{facade.downcase} walls, but no windows were found to add overhangs to.".red)
      return true
    end

    # Get final construction costs and multiply
    yr0_capital_totalCosts += get_total_costs_for_objects(model.getConstructions)

    # Reporting initial condition of model
    number_of_final_space_shading_surf = 0
    final_shading_groups = model.getShadingSurfaceGroups
    final_shading_groups.each do |shading_group|
      number_of_final_space_shading_surf += shading_group.shadingSurfaces.size
    end
    runner.registerFinalCondition("The final building has".green + " #{number_of_final_space_shading_surf}".light_blue + " space shading surfaces. Initial capital costs associated with the improvements are $".green + "#{yr0_capital_totalCosts.round(2)}.".light_blue)
    return true
  end
end

# This allows the measure to be used by the application
NrcAddOverhangsByProjectionFactor.new.registerWithApplication
