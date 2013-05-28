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
    expect(doc_length).to be(35.0)
    expect(term_frequency).to eq(expectation)
  end

  record1 = {:id => '1',
             :notes => 'Annual regional household income news.',
             :resources => [{:description => 'PDF'},
                            {:description => 'XLS'},
                            {:description => 'DOC'}]}
  record2 = {:id => '2',
             :notes => 'Number of people registered to vote in elections.',
             :resources => [{:description => 'PDF'}]}

  expectation = {'annual' => ['1'], 'regional' => ['1'],
                 'household' => ['1'], 'income' => ['1'], 'news' => ['1'],
                 'pdf' => ['1', '2'], 'xls' => ['1'], 'doc' => ['1'],
                 'number' => ['2'], 'of' => ['2'], 'people' => ['2'],
                 'registered' => ['2'], 'to' => ['2'], 'vote' => ['2'],
                 'in' => ['2'], 'elections' => ['2']}

  metadata = [record1, record2]
  subject { Metrics::RichnessOfInformation.new(metadata) }

  it "computes the frequency of a word in all given texts" do
    expect(subject.document_numbers).to be(6.0)
    expect(subject.document_frequency).to eq(expectation)
  end

  it "computes the Term Frequency-Inverse Document Frequency" do
    result = Metrics::RichnessOfInformation.term_frequency(record1)
    term_frequency, doc_length = result
    subject.compute(record1)
    expect(subject.score.round(5)).to be(1.70512)
  end

end
