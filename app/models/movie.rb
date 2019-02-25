require 'mongoid'
require './app/models/person'

class Movie
	include Mongoid::Document

	field :title, type: String
	field :year, type: Integer
	field :rating, type: Integer

	validates :title, presence: true
	validates :year, presence: true
	validates :rating, presence: true, inclusion: 1..5

	index({ title: 1, year: 1 }, { unique: true })
	embedded_in :person
end