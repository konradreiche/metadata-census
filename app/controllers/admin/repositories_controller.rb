class Admin::RepositoriesController < ApplicationController
  helper_method :repository_count

  def new
    @repository_files = repository_files
  end

  def repository_files
    files = Dir.glob('data/repositories/*.yml').select { |f| File.file?(f) }
    files.map do |yaml| 
      { yaml => YAML.load_file(yaml).with_indifferent_access }
    end.reduce(:merge)
  end

  def repository_count(yaml)
    yaml.except(:name).values.map(&:length).reduce(:+)
  end
    
end
