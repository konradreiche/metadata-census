class AdminController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  def control
    load_repositories(:repository)
    load_metrics()
  end

  def importer
    archives = Dir.glob('archives/**/*').select { |fn| File.file?(fn) }
    @archives = archives.inject({}) do |result, archive|
      parts = File.basename(archive).split('-')
      date = DateTime.new(*parts[0..2].map(&:to_i))
      result[archive.split('/').last] = date
      result
    end
  end

  def import
    file = params[:file]
    catalog = YAML.load_file(file)
    catalog = catalog.with_indifferent_access
    catalog.each do |type, repositories|
      repositories.each do |repository|
        attributes = repository.delete("location")
        Repository.new(attributes)
      end
    end

  end

end
