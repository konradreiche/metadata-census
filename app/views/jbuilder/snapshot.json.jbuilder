json.snapshot do
  json.date  @snapshot.date
  json.score @snapshot.score
  Metrics::Metric.all.each do |metric|
    next if @snapshot.send(metric).nil?
    scores = @snapshot.send(metric).select do |key, _|
      ['average'].include?(key)
    end
    json.set!(metric, scores)
  end
end
