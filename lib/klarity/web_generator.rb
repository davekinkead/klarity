# frozen_string_literal: true

require 'erb'
require 'json'

module Klarity
  class WebGenerator
    TEMPLATE_PATH = File.expand_path('templates/graph.html.erb', File.dirname(__FILE__))

    def self.generate(dependency_data)
      new(dependency_data).generate
    end

    def initialize(dependency_data)
      @dependency_data = dependency_data
    end

    def generate
      template = File.read(TEMPLATE_PATH)
      erb = ERB.new(template, trim_mode: '-')

      @data_json = JSON.generate(@dependency_data)
      html_content = erb.result(binding)

      file_path = output_path
      File.write(file_path, html_content)

      file_path
    end

    private

    def output_path
      timestamp = Time.now.strftime('%Y-%m-%d-%H%M%S')
      File.join(ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || '/tmp', "klarity-analysis-#{timestamp}.html")
    end
  end
end
