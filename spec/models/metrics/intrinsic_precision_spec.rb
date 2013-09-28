require 'spec_helper'

describe Metrics::IntrinsicPrecision do

  it "#corpurs" do
    record = { notes: "This is an English text.",
               resources: { description: "Dataset" } }

    metric = Metrics::IntrinsicPrecision.new
    expect(metric.corpus(record)).to eq("This is an English text. Dataset")
  end

  it "#detect_language" do
    record = { notes: "This is an English text.",
               resources: { description: "Dataset" } }

    metric = Metrics::IntrinsicPrecision.new
    expect(metric.language(record)).to eq(:english)

    record = { notes: "Das ist ein deutscher Text.",
               resources: { description: "Datensatz" } }

    metric = Metrics::IntrinsicPrecision.new
    expect(metric.language(record)).to eq(:german)
  end

  it "should determine the number of spelling mistakes" do
    record = { notes: "Is this a aaaatext?" }
    metric = Metrics::IntrinsicPrecision.new
   # score, analysis = metric.compute(record)
    accessor = [:notes]
   # expect(score).to be(0.75) 
   # expect(analysis.first).to eq({ field: accessor, score: 0.75, misspelled: ['aaaatext'] })
  end

  it "should also work on nested records" do
    record = { resources: { description: 'This is a text.' } }
    metric = Metrics::IntrinsicPrecision.new
   # score, analysis = metric.compute(record)
    accessor = [:resources, :description]
   # expect(score).to be(1.0) 
   # expect(analysis.first).to eq({ field: accessor, score: 1.0, misspelled: []})
  end

end
