require 'digest'

class Snapshot
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :date

  has_many :metadata_records

  field :_id, default: -> { Digest::MD5.hexdigest("#{date}#{repository}") }

  field :date, type: Date

  field :repository

  Metrics::list.each do |metric|
    field metric, type: Hash
  end

  belongs_to :repository

end
