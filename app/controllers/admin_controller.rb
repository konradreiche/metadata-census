class AdminController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  def control
    load_repositories(:repository)
    load_metrics()
  end

  def import
  end

end
