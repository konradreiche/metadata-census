class AdminController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  def scheduler
    load_repositories(:repository)
    load_metrics()
  end

end
