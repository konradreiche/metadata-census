class Metrics::CompletenessController < ApplicationController

  helper_method :value

  def details
    @metric = request.path.split("/").last.gsub("-","_").to_sym

    @repositories = Repository.all
    @repository = params[:repository] || @repositories.first.name
    @repository = Repository.find @repository

    @properties = schema_keys(JSON.parse File.read 'public/ckan-schema.json')
    @best = @repository.best_record('completeness')
    @worst = @repository.worst_record('completeness')

    @best = HashWithIndifferentAccess.new @best.to_hash unless @best.nil?
    @worst = HashWithIndifferentAccess.new @worst.to_hash unless @worst.nil?
  end

  # Creates a list of metadata field names. If a field maps to another complex
  # field the key is another array where the first element is the first key.
  def schema_keys schema
    schema["properties"].map do |k, v|
      case v["type"]
      when "array"
        v["items"]["type"] == "object" ? [k] + schema_keys(v["items"]) : k
      when "object"
        v["properties"].nil? ? k : schema_keys(v)
      else
        k
      end
    end.compact
  end

  def value(record, field, i, subfield)
    begin
      record[field][i][subfield]
    rescue NoMethodError
      nil
    end
  end

end
