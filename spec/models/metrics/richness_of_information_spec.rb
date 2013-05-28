require 'spec_helper'

describe Metrics::RichnessOfInformation do

  it "computes the frequency of a word in a given text" do

    data = { :notes    => 'These files provide detailed road safety data '\
                          'about the circumstances of personal injury road '\
                          'accidents in GB from 2005',

            :resources => [{:description => 'Road Safety - Accidents 2005'},
                           {:description => 'Road Safety - Accidents 2006'},
                           {:description => 'Road Safety - Accidents 2007'},
                           {:description => 'Road Safety - Accidents 2008'}]}

    expectation = {'these' => 1, 'files' => 1, 'provide' => 1, 'detailed' => 1,
                   'road' => 6, 'safety' => 5, 'data' => 1, 'about' => 1,
                   'the' => 1, 'circumstances' => 1, 'of' => 1,
                   'personal' => 1, 'injury' => 1, 'accidents' => 5, 'in' => 1,
                   'gb' => 1, 'from' => 1, '2005' => 2, '2006' => 1,
                   '2007' => 1, '2008' => 1}

    result = Metrics::RichnessOfInformation.term_frequency(data)
    term_frequency, doc_length = result
    expect(doc_length).to be(5.0)
    expect(term_frequency).to eq(expectation)
  end

  it "computes the frequency of a word in all given texts" do
  end

  it "computes the Term Frequency-Inverse Document Frequency" do
  end

end
