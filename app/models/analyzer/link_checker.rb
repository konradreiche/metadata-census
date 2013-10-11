class Analyzer::LinkChecker

  def self.analyze(snapshot, metric)
    metadata = snapshot.metadata_records
    metadata = metadata.only("record.id", "#{metric}.analysis")

    metadata.each_with_object({}) do |document, analysis|
      analysis[document.record['id']] = document[metric]['analysis']
    end
  end

end
