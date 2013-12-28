class Analyzer::Accuracy

  def self.analyze(snapshot, metric)
    metadata = MetadataRecord.where(snapshot: snapshot)
    metadata = metadata.only("record.id", "#{metric.id}.analysis")

    metadata.each_with_object({}) do |document, analysis|
      if not document[metric.id].nil?
        analysis[document.record['id']] = document[metric.id]['analysis']
      end
    end.delete_if { |k, v| v.empty? }
  end

end
