# Additional methods used by the measure to gather data for the report.

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Control summary
  class ControlSummary < ReportSection
    def initialize(btap_data: btap_data = nil)
      @content = { title: "Control Performance Overview" }
      @content[:introduction] = "The following is a summary of the control performance in the model. Currently focus is on HVAC temperature set points."

      # Lambdas are preferred over methods in methods for small utility methods.
      #  Sometimes the btap look up returns a nil object. Do not send this to signif.
      nil_signif = lambda do |value, digits = 3|
        return value ? value.signif(digits) : value
      end

      # Define the table content of this section.
      table = ReportTable.new(units: true, caption: "Setpoint Manager Performance Overview.")

      # Grab the set point data array from btap_data.
      setpointArray = btap_data[:setpoint_data]

      # Extract data from hash and ensure it has keys as symbols. Note need "" if there is a - in the symbol.
      data = Array.new
      data << ["Setpoint Manager", "Node", "Maximum temperature Diff", "Minimum temperature Diff", "Mean", "Standard Devtiation"]
      data << [" ", " ", "K", "K", "<sup>o</sup>C", "<sup>o</sup>C"]
      setpointArray.each do |node|
        data << [ node[:setpoint_name], node[:node_name], node[:max_diff].round(2), node[:min_diff].round(2), node[:mean_diff].round(2), node[:stdev_diff].round(2)]
      end
      table.data = data
      table.description = "Table <caption> provides a breakdown of the deviation from setpoints in the simulation."
      add_table_or_chart(table)

      # Add the image of the control.
      # First need to create the image. Dump data to file for processing in R.
      csv = ""
      setpointArray.each do |node|
        puts "#{node[:setpoint_name]}, #{node[:node_name]}".red
        csv << "#{node[:setpoint_name]} [#{node[:node_name]}], "
      end
      csv << "\n"
      setpointArray.first[:deltaT].each_index do |i|
        row = ""
        setpointArray.each do |node|
          row << "#{node[:deltaT][i]}, "
        end
        csv << row << "\n"
      end
      File.open('./setpoint.csv', 'w') { |f| f.write(csv) }
  

 # Dumping this here for now.
    puts "-----------------------".red
    system "which Rscript"
    puts "-----------------------".green

    rfile=File.expand_path("#{File.dirname(__FILE__)}/boxplot.r")
    system "Rscript #{rfile} setpoint.csv setpoint_plot.png"

    # Check if R works
    # https://github.com/clbustos/Rserve-Ruby-client
    #c = Rserve::Connection.new
    #x = c.eval("R.version.string")
    #puts "#{x.as_string}".yellow

    #xx = [1, 2, 3, 4]
    #yy = [2, 4, 5, 3]
    #puts x.class
    #c.assign("x", xx)
    #c.assign("y", yy)
    #outfile=File.expand_path("#{File.dirname(__FILE__)}/rplot.jpg")
    #result = c.eval("jpeg('#{outfile}'); plot(x,y); dev.off()")

    #puts "R eval #{result.class}; #{result}"

    end
  end


    #data = { simulation_openstudio_version: qaqc_data[:openstudio_version].split('+')[0],
     #        simulation_openstudio_revision: qaqc_data[:openstudio_version].split('+')[1],
      #       simulation_energyplus_version: qaqc_data[:energyplus_version]
    #}
  # Gather the data required for the setpoint summary and return in a hash. 
  # Called from the main measure.
  def gatherSetpointSummary(model)
    numSetPointManagers = model.getSetpointManagers.size + 1 # If none then return an empty hash?

    # Get the sql file (this is set in the main measure).
    sqlFile = nil
    if (model.sqlFile) then
      sqlFile = model.sqlFile.get
    end
    puts "#{sqlFile}".red

    # Confirm that this is not a design day simulation.
    ann_env_pd = nil
    sqlFile.availableEnvPeriods.each do |env_pd|
      env_type = sqlFile.environmentType(env_pd)
      if env_type.is_initialized
        if env_type.get == OpenStudio::EnvironmentType.new("WeatherRunPeriod")
          ann_env_pd = env_pd
          break
        end
      end
    end

    # Recover the variable names in the sql file that correspond to a time series.
    # Filter list to only select ones that have temperature data.
    reporting_frequency = "Hourly" # This could be Hourly or Daily and needs to be cordinated with the measure arguments.
    variable_names = sqlFile.availableVariableNames(ann_env_pd, reporting_frequency).select { |var| var.include? "Temperature" }
    puts "Selected time series variable names: #{variable_names}".yellow

    # Create an array with all the setpoint managers nodes. Then loop through these to recover the time series data.
    #  When working on an individual setpoint manager add all data to node_timeseries array. The data is then extracted 
    #  from that array into individual vectors and re-combined into the setpoint_data array (the return value of this method).
    setpoint_data = []
    setPoints = model.getSetpointManagers
    puts "Setpoints object count: #{setPoints.size}".red
    setPoints.each do |setPoint|
      node_name = "#{setPoint.setpointNode.get.name}"
      setpoint_name = "#{setPoint.name}"
      puts "Setpoints : #{node_name}; #{setpoint_name}".light_blue
      node_timeseries = []
      variable_names.each do |variable_name|
        timeseries = sqlFile.timeSeries(ann_env_pd, reporting_frequency, variable_name.to_s, node_name.to_s)

        # The call above returns a single time series. Here we want to combine these into one larger array with 
        #  a timestamp and column of data.
        if !timeseries.empty?
          timeseries = timeseries.get
          units = timeseries.units
          values = timeseries.values
          datetime = timeseries.dateTimes.map { |t| t.to_s }
          header = "#{node_name}:#{variable_name}"
          node_timeseries << {item: header, data: {datetime: datetime, values: values, units: units}}
        else
          puts "Timeseries for #{node_name} #{variable_name} is empty.".yellow
        end
      end

      # node_timeseries array now contains the node temperature and setpoint temperature timeseries in their hashes.
      #  need to calculate the difference between them.
      #  extract the nodeT and the setpointT and one of the dateTime series (we can assume these have the same values,
      #  then create a new vector with the diff.
      puts "#{node_timeseries}".yellow
      dateTime = node_timeseries[0][:data][:datetime]
      units = node_timeseries[0][:data][:units]
      nodeTindex = node_timeseries.index { |element| element[:item].include?("Node Temperature")}
      puts "#{nodeTindex}".green
      nodeT = node_timeseries[nodeTindex][:data][:values]
      setpointTindex = node_timeseries.index { |element| element[:item].include?("Node Setpoint Temperature")}
      setpointT = node_timeseries[setpointTindex][:data][:values]
      puts "#{dateTime.length}, #{nodeT.length}, #{setpointT.length}".blue

      # Calculate the difference on node T from setpoint and add to new vector.
      diffT = []
      nodeT.zip(setpointT).each do |node, setpoint|
        diffT << node - setpoint
      end
      puts "#{diffT.length}".green


      # Calculate statistics of the diffT vector.
      max_tempDiff = diffT.max
      min_tempDiff = diffT.min
      mean = diffT.sum(0.0) / diffT.length
      sum_sqr = diffT.sum(0.0) { |item| (item - mean) ** 2}
      variance = sum_sqr / (diffT.length - 1)
      std_dev = Math.sqrt(variance)
      puts "#{std_dev}".green

      # Have all the data now for this node. Add to the hash that gets returned here.
      hash = {node_name: node_name, 
              setpoint_name: setpoint_name, 
              units: units, 
              dateTime: dateTime, 
              nodeT: nodeT,
              setpointT: setpointT,
              deltaT: diffT,
              max_diff: max_tempDiff,
              min_diff: min_tempDiff,
              mean_diff: mean,
              stdev_diff: std_dev}
      setpoint_data << hash
    end

    puts "#{setpoint_data}".light_blue

    return {setpoint_data: setpoint_data}
  end
end