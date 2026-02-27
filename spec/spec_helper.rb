# frozen_string_literal: true

require 'stringio'
require 'klarity'
require 'rspec'

module OutputCapture
  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end

RSpec.configure do |config|
  config.include OutputCapture

  original_stderr = $stderr
  $stderr = StringIO.new

  config.after(:suite) do
    $stderr = original_stderr
  end
end
