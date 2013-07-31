class AdminController < ApplicationController
  include Concerns::Repository

  helper_method :status

  def control
    load_repositories(:repository)
    @metrics = Metrics::IDENTIFIERS
    gon.metrics = @metrics
  end

  def status(metric)
    not @repository.send(metric).nil?
  end

end
