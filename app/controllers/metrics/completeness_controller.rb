class Metrics::CompletenessController < ApplicationController

  def details
    @repositories = Repository.all
    @repository = params[:repository] || @repositories.first.name
    @worst = worst_record.completeness
    @best = best_record
  end

  def worst_record
    sort_completeness('asce').first
  end

  def best_record
    sort_completeness('desc').first
  end

  def sort_completeness how
    repository = @repository
    search = Tire.search 'metadata' do
      query { string "repository:#{repository}" }
      sort { by :completeness, how }
    end.results
  end

end
