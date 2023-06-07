# Interface/template classes that report sections and content inherit from.
#
# Define these in the scope of the measure's class.
require 'json'

class NrcReportingMeasureStandard < OpenStudio::Measure::ReportingMeasure

  # Interface class. Defines all possible content and interface to concrete section objects.
  # The section has a title and overall description. It then has an array of tables and charts.
  class ReportSection
    attr_reader :content

    def initialize()
      @content = { title: nil, introduction: nil, tables_and_charts: nil } # The initialisation does nothing, just a way to highlight the expected keys.
    end

    def add_table_or_chart(table_or_chart)
      (@content[:tables_and_charts] ||= []) << table_or_chart # Fancy way of creating the key or adding to the existing key.
    end

    def to_json(*args)
      {
        :class => self.class.name,
        :content => content
      }.to_json(*args)
    end
  end

  # Template for a table. Can be either by row or by column (default is columns will be the titles and
  #  rows will have the data, thus by_row=false and row_names will be empty)
  class ReportTable
    attr_writer :data, :description

    def initialize(by_row: by_row = false, units: units = false, caption: nil)
      @table = { by_row: by_row, units: units, caption: caption, data: nil, description: nil }
    end

    def content
      # Ensure that the content of the table is up to date. Return the table object.
      @table.merge!(data: @data)
      @table.merge!(description: @description)
    end

    def to_json(*args)
      {
        :class => self.class.name,
        :content => content
      }.to_json(*args)
    end
  end

  # Template for a chart. 
  class ReportChart
    attr_writer :file, :description

    def initialize(caption: nil)
      @chart = { caption: caption, description: nil }
    end

    def content
      # Ensure that the content of the chart is up to date. Return the chart object.
      @chart.merge!(file: @file)
      @chart.merge!(description: @description)
    end

    def to_json(*args)
      {
        :class => self.class.name,
        :content => content
      }.to_json(*args)
    end
  end
end