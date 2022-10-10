# frozen_string_literal: true

ActiveAdmin.register Analytic do
  includes :event, :owner
  actions :all, except: %i[new edit destroy]

  filter :owner_type
  filter :owner_id
  filter :event
  filter :created_at
  filter :updated_at

  index pagination_total: false do
    column :events do |analytic|
      analytic.event&.name
    end
    column :owners, &:owner
    column :created_at
    actions
  end

end
