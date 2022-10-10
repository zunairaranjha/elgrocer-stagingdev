class Event < ActiveRecord::Base

  has_many :analytics

  validates_presence_of :name
  validates :name, uniqueness: true

end
