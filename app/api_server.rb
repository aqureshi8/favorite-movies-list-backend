require 'net/http'
require 'uri'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'sinatra/namespace'
require './app/models/movie'

Mongoid.load! "./app/config/mongoid.config"

before do
	response.headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

helpers do
  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
end

get '/' do
	"Welcome to the favorite movies list Api"
end

namespace '/api' do

	before do
		content_type 'application/json'
	end

	get '/movies' do
		Movie.all.to_json
	end

	get '/search' do
		title = params[:title]
		Net::HTTP.get URI('http://www.omdbapi.com/?apikey='+ config['omdb_key'] + '&s=' + title)
	end

	post '/favorites' do
		username = json_params['username']
		Person.where(username: username).to_json
	end
end