# Check diffs.
require 'openstudio'
require 'openstudio-standards'

def read_model(osm_file)

  model = OpenStudio::Model::Model.new
  #osm_file = "#{File.expand_path(__dir__)}/regression_models/#{filename}"
  unless File.exist?(osm_file)
    puts "ERROR: The model: #{osm_file} does not exist."
    return model
  end
  osm_model_path = OpenStudio::Path.new(osm_file.to_s)

  # Upgrade version if required.
  version_translator = OpenStudio::OSVersion::VersionTranslator.new
  model = version_translator.loadModel(osm_model_path).get
end

#model_file_A = "NECB2015-Warehouse-Thompson_EWY_3.osm"
#model_file_B = "Warehouse-NECB2015-Thompson_EWY_3.osm"
model_file_A = ""
model_file_B = ""

Dir["#{File.expand_path(__dir__)}/regression_models/NECB*osm"].each do |file|
  model_file_A = file
  ["NECB2011", "NECB2015", "NECB2017", "NECB2020"].each do |code|
    if file.match? ("#{code}")
      cutfile = file.sub("#{code}-", "")
      #puts cutfile.sub("-", "-#{code}-")
      model_file_B = cutfile.sub("-", "-#{code}-")
    end
  end

  model_A = read_model(model_file_A)
  model_B = read_model(model_file_B)

  diffs = BTAP::FileIO::compare_osm_files(model_A, model_B)

  #puts diffs
  File.write(model_file_A.sub(".osm", ".txt"), JSON.pretty_generate(diffs))
end


