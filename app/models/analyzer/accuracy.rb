class Analyzer::Accuracy

  def self.analyze(snapshot, metric)
    metadata = MetadataRecord.where(snapshot: snapshot)
    metadata = metadata.only("record.id", "#{metric}.analysis")

    metadata.each_with_object({}) do |document, analysis|
      if document[metric].nil?
        analysis[document.record['id']] = []
      else
        analysis[document.record['id']] = document[metric]['analysis']
      end
    end
  end

end
