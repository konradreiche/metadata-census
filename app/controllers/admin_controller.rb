class AdminController < ApplicationController
  include Concerns::Repository
  include Concerns::Metric

  def control
    load_repositories(:repository)
    load_metrics()
  end

  def import
    archives = Dir.glob('archives/**/*').select { |fn| File.file?(fn) }
    @archives = archives.inject({}) do |result, archive|
      parts = File.basename(archive).split('-')
      date = DateTime.new(*parts[0..2].map(&:to_i))
      result[archive.split('/').last] = date
      result
    end
  end

end
