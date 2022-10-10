class Banner < ActiveRecord::Base
  attr_accessor :select_all_retailers
  has_and_belongs_to_many :retailers
  has_many :banner_links
  # validates_presence_of :title, :title_ar
  accepts_nested_attributes_for :banner_links, allow_destroy: true

  enum banner_type: { in_all: 0, in_store: 1, in_search: 2, in_home: 3, in_home_and_store: 4  }
  
end
