require 'digest'

class Snapshot
  include Mongoid::Document
  include Mongoid::Extensions::Hash::IndifferentAccess

  validates_presence_of :date

  field :_id, default: -> { Digest::MD5.hexdigest("#{date}#{repository}") }

  field :date, type: Date

  field :records, type: Array, default: -> { Array.new }

  Metrics::list.each do |metric|
    field metric, type: Hash
  end

  belongs_to :repository

end
