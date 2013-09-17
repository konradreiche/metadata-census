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
      metadata = parser.parse(file)
      Metadata.create!(_metadata)
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
    records = parsed[:metadata].map do |record|
      Metadata.new(record, type, repository, date)
    end

    Tire.index 'metadata' do
      create
      import records
    end

  end

end
