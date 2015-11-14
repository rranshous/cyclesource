require_relative 'state'
require_relative 'http_interface'

# create persistant state
state_path = File.join((ENV['DATA_DIR'] || './data'), 'skyscraper.lmc')
state = State.new(state_path)

begin
  http_interface! state
end
