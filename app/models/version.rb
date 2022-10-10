class Version < ActiveRecord::Base
  validates_presence_of :majorversion
  validates_presence_of :minorversion
  validates_presence_of :revision
end
