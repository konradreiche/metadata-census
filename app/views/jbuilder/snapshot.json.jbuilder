json.snapshot do
  json.date  @snapshot.date
  json.score @snapshot.score
  Metrics::Metric.all.each do |metric|
    next if @snapshot.send(metric.id).nil?
    scores = @snapshot.send(metric.id).select do |key, _|
      ['average'].include?(key)
    end
    json.set!(metric, scores)
  end
end
