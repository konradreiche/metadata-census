class MetricsReportController < ApplicationController

  def report
    @repositories = Repository.all
    @repository = params[:repository] || @repositories.first.name
    @repository = Repository.find(@repository)
  end

  def metric
    metric = self.class.name.split('Controller').underscore.to_sym
  end

end
