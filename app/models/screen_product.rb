class ScreenProduct < ActiveRecord::Base
  belongs_to :screen, optional: true
  belongs_to :product, optional: true
end
