class AdminController < ApplicationController
  include Concerns::Repository

  def control
    load_repositories(:repository)
    @metrics = Metrics::IDENTIFIER
    gon.metrics = @metrics
  end


end
