require "sinatra/base"
require 'json'
require_relative 'dockerface'
require 'pry'

class HttpInterface < Sinatra::Base

  before do
    request.body.rewind
    body = request.body.read
    @post_data = JSON.parse(body) unless body.empty?
  end

  post '/start' do
    image_path = @post_data['image'].chomp
    puts "image_path: #{image_path}"
    image_id = Dockerface.start_container image_path
    content_type :json
    { id: image_id }.to_json
  end

  get '/status/:container_id' do |container_id|
    status = Dockerface.status(container_id)
    halt 404 if status == false
    content_type :json
    status.to_json
  end

  post '/stop/:container_id' do |container_id|
    success = Dockerface.stop container_id, 10
    halt 404 if !success
    halt 204
  end

  #post '/set_callback' do
  #  callback = params[:callback].chomp
  #  puts "setting callback: #{callback}"
  #  settings.state['callback'] = callback
  #  content_type :text
  #  redirect '/'
  #end

  #get '/' do
  #  erb :index, locals: { state: settings.state }
  #end
end

def http_interface! state
  HttpInterface.set :state, state
  puts "running sinatra app"
  HttpInterface.run!
  puts "done running app"
end