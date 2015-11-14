require 'thread'

# don't need to sync b/c state obj does and it's our only state
class Tracker
  def initialize state
    @state = state
  end

  def running_containers
    @state['running_containers']
  end

  def container_started container_id
    running_containers = @state['running_containers'] ||= []
    @state['running_containers'] = running_containers + [ container_id ]
  end

  def container_stopped container_id
    running_containers = @state['running_containers'] ||= []
    running_containers.delete container_id
    @state['running_containers'] = running_containers
  end

end
