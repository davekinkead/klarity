#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/klarity'

puts 'Analyzing spec/fixtures/sample_app...'
puts '=' * 60

result = Klarity.analyze('spec/fixtures/sample_app')

result.each do |class_name, dependencies|
  puts "\n#{class_name}:"
  puts "  Messages: #{dependencies[:messages].inspect}"
  puts "  Inherits: #{dependencies[:inherits].inspect}"
  puts "  Includes: #{dependencies[:includes].inspect}"
  puts "  Dynamic: #{dependencies[:dynamic]}"
end

puts "\n" + '=' * 60
puts "Total classes/modules analyzed: #{result.keys.length}"
