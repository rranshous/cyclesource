require_relative 'state'
require_relative 'http_interface'
require_relative 'tracker'
require_relative 'background_work'

require 'thread'
Thread.abort_on_exception = true

# create persistant state
state_path = File.join((ENV['DATA_DIR'] || './data'), 'skyscraper.lmc')
puts "state path: #{state_path}"
state = State.new(state_path)

tracker = Tracker.new state

background_thread = nil
begin
  background_thread = Thread.new do
    BackgroundWork.start! tracker
  end

  http_interface! tracker

ensure
  puts "stopping background thread"
  background_thread.kill if background_thread
end

puts "done in main"
