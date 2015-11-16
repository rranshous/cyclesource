require "sinatra/base"
require 'json'
require_relative 'dockerface'

class HttpInterface < Sinatra::Base

  before do
    request.body.rewind
    body = request.body.read
    @post_data = JSON.parse(body) unless body.empty?
  end

  post '/start' do
    image_path = @post_data['image'].chomp
    puts "image_path: #{image_path}"
    container_id = Dockerface.start_container image_path
    puts "updating tracker"
    settings.tracker.container_started container_id
    puts "done starting"
    content_type :json
    { id: container_id }.to_json
  end

  get '/status/:container_id' do |container_id|
    status = Dockerface.status(container_id)
    halt 404 if status == false
    content_type :json
    puts "request host: #{request.host}"
    status.merge!({
      host: request.host
    })
    status.to_json
  end

  post '/stop/:container_id' do |container_id|
    success = Dockerface.stop container_id, 10
    halt 404 if !success
    settings.tracker.container_stopped container_id
    halt 204
  end
end

def http_interface! tracker
  ENV['HOST'] ||= '0.0.0.0'
  ENV['PORT'] ||= '8080'
  HttpInterface.set :tracker, tracker
  HttpInterface.set :bind, ENV['HOST']
  HttpInterface.set :port, ENV['PORT']

  puts "running sinatra app"
  HttpInterface.run!
  puts "done running app"
end
