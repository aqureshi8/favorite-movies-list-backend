require 'net/http'
require 'uri'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'sinatra/namespace'
require './app/models/movie'
require 'app_configuration'

Mongoid.load! "./app/config/mongoid.config"

config = AppConfiguration.new

before do
	response.headers['Access-Control-Allow-Origin'] = 'https://favorite-movies-list-frontend.herokuapp.com'
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

	get '/eraseTester' do
		person = Person.where(username: 'tester')
		person[0].movies.delete_all
		200
	end

	post '/search' do
		title = json_params['title']
		Net::HTTP.get URI('http://www.omdbapi.com/?apikey='+ config['omdb_key'] + '&s=' + title)
	end

	post '/favorites' do
		username = json_params['username']
		Person.where(username: username).to_json
	end

	post '/addFavorite' do
		jparams = json_params
		person = Person.find_or_create_by(username: jparams['username'])
		movie = person.movies.where(title: jparams['title'], year: jparams['year'])
		if movie.to_json != '[]'
			movie.delete
		end
		person.movies << Movie.new(
			title: jparams['title'],
			year: jparams['year'],
			poster: jparams['poster'],
			rating: jparams['rating'],
			comment: jparams['comment']
		)
		200		
	end

	post '/getMovie' do
		imdbId = json_params['id']
		Net::HTTP.get URI('http://www.omdbapi.com/?apikey=' + config['omdb_key'] + '&i=' + imdbId)
	end

	post '/removeMovie' do
		jparams = json_params
		p jparams
		person = Person.find_or_create_by(username: jparams['username'])
		movie = person.movies.where(title: jparams['title'], year: jparams['year'])
		movie[0].delete
		200
	end
end