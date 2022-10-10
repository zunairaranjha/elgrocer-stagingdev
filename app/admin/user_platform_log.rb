# frozen_string_literal: true

ActiveAdmin.register UserPlatformLog do
  actions :all, except: %i[new destroy edit]
  menu parent: 'Shoppers'

  includes :shopper


  remove_filter :shopper

end
