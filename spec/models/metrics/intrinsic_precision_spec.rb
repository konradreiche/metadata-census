require 'spec_helper'

describe Metrics::IntrinsicPrecision do

  it "#corpurs" do
    record = { 'notes' => "This is an English text.",
               'resources' => { 'description' => "Dataset" } }

    metric = Metrics::IntrinsicPrecision.instance
    expect(metric.corpus(record)).to eq("This is an English text. Dataset")
  end

  it "#language" do
    record = { 'notes' => "Das ist ein deutscher Text.",
               'resources' => { 'description' => "Datensatz" } }

    metric = Metrics::IntrinsicPrecision.instance
    expect(metric.language(record)).to eq(:german)
  end

  it "detect common spelling mistakes" do
    record = { 'notes' => "Die Addresse seiner Wohnung lautet" }

    metric = Metrics::IntrinsicPrecision.instance
    score, analysis = metric.compute(record)

    accessor = ['notes']
    expect(score).to be(0.0) 
    expect(analysis.first).to eq({ field: accessor, score: 0.0, language: :german, misspelled: ['Addresse'] })
  end

  it "should also work on nested records" do
    record = { 'notes' => 'Die Adresse des Hauses lautet',
               'resources' => { 'description' => 'Turbolenzen' } }

    metric = Metrics::IntrinsicPrecision.instance
    score, analysis = metric.compute(record)

    expect(score).to be(0.0) 
    expect(analysis[0]).to eq({ field: ['notes'], language: :german, score: 1.0, misspelled: [] })
    expect(analysis[1]).to eq({ field: ['resources', 'description'], language: :german, score: 0.0, misspelled: ['Turbolenzen'] })
  end

end
