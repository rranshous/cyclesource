require 'docker'

class Dockerface
  def self.start_container image_path
    opts = {
      Image: image_path,
      HostConfig: {
        PublishAllPorts: true
      }
    }
    puts "getting container"
    system("./bin/docker pull #{image_path}")
    puts "creating container"
    container = Docker::Container.create opts
    puts "starting container: #{container.id}"
    container.start
    puts "done starting: #{container.id}"
    container.id
  end

  def self.status container_id
    begin
      container = Docker::Container.get container_id
    rescue Docker::Error::NotFoundError
      return false
    end

    status = container.json
    {
      running: running?(status),
      ports: detail_ports(status),
      created_at: status['Created']
    }
  end

  def self.stop container_id, kill_after_seconds
    begin
      container = Docker::Container.get container_id
    rescue Docker::Error::NotFoundError
      return false
    end
    container.stop({ timeout: kill_after_seconds }).id
    container.wait kill_after_seconds
  end

  def self.running_containers
    Docker::Container.all.map(&:id)
  end

  private

  def self.detail_ports container_json
    ports = {}
    port_data = container_json["NetworkSettings"]["Ports"]
    return [] if port_data.nil?
    port_data.each do |container_port_desc, binding_details|
      container_port = container_port_desc.split('/').first.to_i
      host_port = binding_details.first['HostPort'].to_i
      ports[container_port] = host_port
    end
    return ports
  end

  def self.running? container_json
     container_json['State']['Running']
  end
end
