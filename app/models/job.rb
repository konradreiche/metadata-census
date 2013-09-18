require 'digest'

class Job
  include Mongoid::Document

  validates_presence_of :id, :repository, :metric

  field :id
  field :repository
  field :metric

  field :_id, default: -> { Digest::MD5.hexdigest("#{repository} #{metric}") }

end
