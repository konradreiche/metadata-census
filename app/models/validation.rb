module Validation

  def self.uniform_sample(repository, metric, n, idx=0)
    total = repository.total
    metadata = repository.sort_metric_scores(metric, :asc, total)
    metadata.each_slice(total / n).to_a.map { |partition| partition[idx].to_hash }
  end

end
