# frozen_string_literal: true

module ResponseStatuses
  SUCCESSFUL_HTTP_STATUS = [200, 201, 202, 203, 204, 205, 206].freeze
  ACCEPTED_STATUS = %w[Authorised Received Pending].freeze
  ERROR_STATUS = %w[Refused Error Cancelled].freeze
  REDIRECT_STATUS = %w[IdentifyShopper PresentToShopper ChallengeShopper RedirectShopper].freeze
end
