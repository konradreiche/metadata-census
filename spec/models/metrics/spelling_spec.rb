require 'spec_helper'

describe Metrics::Spelling do

  it "#detect_language" do
    record = { notes: "This is a text." }
    metric = Metrics::Spelling.new
    expect(metric.detect_language(record)).to eq(:english)
  end

  it "should determine the number of spelling mistakes" do
    record = { notes: "Is this a aaaatext?" }
    metric = Metrics::Spelling.new
    score, analysis = metric.compute(record)
    accessor = [:notes]
    expect(score).to be(0.75) 
    expect(analysis[accessor]).to eq({ score: 0.75, misspelled: ['aaaatext'] })
  end

  it "should also work on nested records" do
    record = { resources: { description: 'This is a text.' } }
    metric = Metrics::Spelling.new
    score, analysis = metric.compute(record)
    accessor = [:resources, :description]
    expect(score).to be(1.0) 
    expect(analysis[accessor]).to eq({ score: 1.0, misspelled: []})
  end

end
