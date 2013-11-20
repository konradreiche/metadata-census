require 'digest'

class Job
  include Mongoid::Document

  validates_presence_of :sidekiq_id, :repository, :metric

  field :sidekiq_id

  field :repository
  field :snapshot
  field :metric

  field :_id, type: String, overwrite: true, default: -> { Digest::MD5.hexdigest("#{repository} #{snapshot} #{metric}") }

end
