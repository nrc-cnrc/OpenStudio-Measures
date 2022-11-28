#!/usr/bin/env ruby
require 'csv'
require 'json'

extracted_data = CSV.parse(File.read('natural_gas_emission_factors_nir2022.csv'), headers: true)
transformed_data = extracted_data.map { |row| row.to_hash }

File.open('natural_gas_emission_factors_nir2022.json','w') do |f|
  f.puts JSON.pretty_generate(transformed_data)
end