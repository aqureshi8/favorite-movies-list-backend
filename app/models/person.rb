require 'mongoid'

class Person
	include Mongoid::Document
	field :username, type: String
	embeds_many :movies

	validates :username, presence: true
end
