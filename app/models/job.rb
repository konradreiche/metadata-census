require 'digest'

class Job
  include Mongoid::Document

  validates_presence_of :sidekiq_id, :repository, :metric

  field :sidekiq_id
  field :repository
  field :metric

  field :_id, default: -> { Digest::MD5.hexdigest("#{repository} #{metric}") }

end
