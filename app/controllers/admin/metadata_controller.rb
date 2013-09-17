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
      meta_metadata = parser.parse(file)
      attributes = meta_metadata(meta_metadata)
      meta_metadata[:metadata].each do |metadata|
        attributes[:record] = metadata
        Metadata.create!(attributes)
      end
    end

    render nothing: true
  end

  private

  ##
  # Retrieves the meta-metadata.
  #
  def meta_metadata(metadata)
    fields = Metadata.fields.keys.map(&:to_sym)
    metadata.keys.inject({}) do |meta_metadata, key|
      meta_metadata[key] = metadata[key] if fields.include?(key)
      meta_metadata
    end

  end

end
