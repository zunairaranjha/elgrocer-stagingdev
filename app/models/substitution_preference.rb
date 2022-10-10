class SubstitutionPreference < ActiveRecord::Base
  belongs_to :category, optional: true
  belongs_to :shopper, optional: true
end
