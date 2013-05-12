class Metrics::CompletenessController < ApplicationController

  def details
    @metric = request.path.split("/").last.gsub("-","_").to_sym

    @repositories = Repository.all
    @repository = params[:repository] || @repositories.first.name

    @properties = schema_keys(JSON.parse File.read 'public/ckan-schema.json')
    @best = best_record
    @worst = worst_record
    @best = HashWithIndifferentAccess.new @best.to_hash unless @best.nil?
    @worst = HashWithIndifferentAccess.new @worst.to_hash unless @worst.nil?
  end

  def schema_keys schema

    schema["properties"].map do |k, v|
      case v["type"]
      when "array"
        v["items"]["type"] == "object" ? { k => schema_keys(v["items"]) } : k
      when "object"
        v["properties"].nil? ? k : schema_keys(v)
      else
        k
      end
    end.compact
  end

  def worst_record
    sort_completeness('asc').first
  end

  def best_record
    sort_completeness('desc').first
  end

  def sort_completeness how
    repository = @repository
    metric = @metric
    search = Tire.search 'metadata' do
      query { string "repository:#{repository}" }
      sort { by metric.to_s, how }
    end.results
  end

end
