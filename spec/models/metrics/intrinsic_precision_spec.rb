require 'spec_helper'

describe Metrics::IntrinsicPrecision do

  it "#corpurs" do
    record = { notes: "This is an English text.",
               resources: { description: "Dataset" } }

    metric = Metrics::IntrinsicPrecision.new(:english)
    expect(metric.corpus(record)).to eq("This is an English text. Dataset")
  end

  it "#language" do
    record = { notes: "Das ist ein deutscher Text.",
               resources: { description: "Datensatz" } }

    metric = Metrics::IntrinsicPrecision.new(:german)
    expect(metric.language(record)).to eq(:german)
  end

  it "detect common spelling mistakes" do
    record = { notes: "Die Addresse des Hauses lautet" }

    metric = Metrics::IntrinsicPrecision.new(:german)
    score, analysis = metric.compute(record)

    accessor = [:notes]
    expect(score).to be(0.0) 
    expect(analysis.first).to eq({ field: accessor, score: 0.0, misspelled: ['Addresse'] })
  end

  it "should also work on nested records" do
    record = { notes: 'Die Adresse des Hauses lautet',
               resources: { description: 'Turbolenzen' } }

    metric = Metrics::IntrinsicPrecision.new(:german)
    score, analysis = metric.compute(record)

    expect(score).to be(0.0) 
    expect(analysis[0]).to eq({ field: [:notes], score: 1.0, misspelled: [] })
    expect(analysis[1]).to eq({ field: [:resources, :description], score: 0.0, misspelled: ['Turbolenzen'] })
  end

end
