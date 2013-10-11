class Analyzer::RichnessOfInformation < Analyzer::Generic

  class << self
    alias_method :__analyze__, :analyze
  end

  def self.analyze(snapshot, metric)
    generic = __analyze__(snapshot, metric)
    dn = snapshot[metric]['analysis']['document_numbers'].to_i
    
    df = snapshot[metric]['analysis']['document_frequency']
    df = df.sort_by { |word, count| count }.reverse.take(100)

    cf = snapshot[metric]['analysis']['categorical_frequency']
    cf = cf.each_with_object({}) do |(field,counts),cfs|
      cfs[field] = counts.sort_by { |word, count| count }.reverse.take(100)
    end

    generic['categorical_frequency'] = cf
    generic['document_frequency'] = df
    generic['document_numbers'] = dn

    return generic
  end

end
