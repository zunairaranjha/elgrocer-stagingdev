class DataArchive < ApplicationRecord
  belongs_to :owner, optional: true, polymorphic: true

end
