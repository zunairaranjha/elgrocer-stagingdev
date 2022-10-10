class ProductProposalCategory < ApplicationRecord
  belongs_to :product_proposal
  belongs_to :category
end
