class Metrics::CompletenessController < ApplicationController

  def details
    @repositories = Repository.all
  end

end
