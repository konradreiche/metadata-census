require 'yajl'

class Admin::MetadataController < ApplicationController
  include Concerns::Repository

  before_filter :init

  def init
    load_repositories(:repository_id)
  end

  def create
    file = params[:file]
    parser = Yajl::Parser.new(symbolize_keys: true)

    File.open(file) do |file|
      parsed = parser.parse(file)
      index(parsed)
    end

    render nothing: true
  end

  private

  ##
  # Indexes the metadata to the database.
  #
  def index(parsed)
    type = 'ckan'
    date = parsed[:date]
    repository = @repository.id

    parsed[:metadata].each_with_index do |metadata, i|

      Tire.index 'metadata' do
        create
        store Metadata.new(metadata, type, repository, date)
      end

    end
  end

end
