class Analyzer::Availability

  def self.analyze(snapshot, metric)
    metadata = MetadataRecord.where(snapshot: snapshot)
    metadata = metadata.only("record.id", "#{metric.id}.analysis")

    metadata.each_with_object({}) do |document, analysis|
      analysis[document.record['id']] = document[metric.id].maybe['analysis']
      analysis[document.record['id']] = [] if analysis[document.record['id']].nil?
      #analysis.values.flatten.each do |value|
      #  value.encode!('UTF-8', :invalid => :replace) if value.is_a?(String)
      #end
    end
  end

end
