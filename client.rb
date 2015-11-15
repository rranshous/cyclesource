require 'httparty'
require 'json'
require 'uri'

service_url = ARGV.shift
puts "Service: #{service_url}"
command = ARGV.shift
case command
when 'start'
  image_id = ARGV.shift
  puts "starting container from #{image_id}"
  url = URI.join(service_url, 'start')
  r = HTTParty.post(url, body:{ image: image_id }.to_json)
  puts r.parsed_response

when 'status'
  container_id = ARGV.shift
  puts "status of #{container_id}"
  r = HTTParty.get(URI.join(service_url, '/status/', container_id))
  if r.code == 404
    puts "container not found"
  else
    puts r.parsed_response
  end

when 'stop'
  container_id = ARGV.shift
  puts "status of #{container_id}"
  r = HTTParty.post(URI.join(service_url, '/stop/', container_id))
  if r.code == 404
    puts "container not found"
  else
    puts "success"
  end

else
  puts "command [#{command}] not recignized"

end
