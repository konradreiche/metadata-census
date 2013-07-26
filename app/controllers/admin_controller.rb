class AdminController < ApplicationController

  def control
    @metrics = Metrics::IDENTIFIER
  end

end
