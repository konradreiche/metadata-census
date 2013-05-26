class Metrics::RichnessOfInformationController < ApplicationController

  def details
    @repositories = Repository.all
  end

end
