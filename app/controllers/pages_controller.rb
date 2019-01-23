class PagesController < ApplicationController
  # include BlacklightGoogleAnalytics::ControllerExtraHead
  layout 'pages'

  # Just a dumb method for the LB to call to check that rails is responding to controller#actions
  def rails_status
    @rails_healthy = true

    if @rails_healthy
      render layout: false
    else
      render layout: false, status: 500
    end
  end

end