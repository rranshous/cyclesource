require_relative 'dockerface'

class BackgroundWork

  SLEEP_TIME = 10
  MAX_AGE = 5 * 60

  def self.start! tracker
    puts "starting background work loop"
    loop do
      sleep SLEEP_TIME
      container_ids = Dockerface.running_containers
      container_ids.each do |container_id|
        next unless tracker.running_containers.include? container_id
        puts "background checking #{container_id}"
        container_status = Dockerface.status container_id
        if age_in_seconds(container_status) > MAX_AGE
          puts "stopping"
          Dockerface.stop container_id, 10
          tracker.container_stopped container_id
        end
      end
    end
  ensure
    puts "exiting background work loop"
  end

  private

  def self.age_in_seconds container_status
    created_at = DateTime.parse(container_status[:created_at])
    age = Time.now.to_i - created_at.strftime('%s').to_i
    puts "Age in seconds: #{age}"
    age
  end

end
