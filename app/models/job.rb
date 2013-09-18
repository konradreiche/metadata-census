class Job
  include Mongoid::Document

  validates_presence_of :_id, :repository, :metric

  field :_id
  field :repository
  field :metric

end
