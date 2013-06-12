require 'spec_helper'

describe Metrics::RichnessOfInformation do

  it "computes the frequency of a word in a given text" do

    notes = 'These files provide detailed road safety data '\
            'about the circumstances of personal injury road '\
            'accidents in GB from 2005'

    expectation = Hash.new
    expectation['these']         = 1
    expectation['files']         = 1
    expectation['provide']       = 1
    expectation['detailed']      = 1
    expectation['road']          = 2
    expectation['safety']        = 1
    expectation['data']          = 1
    expectation['about']         = 1
    expectation['the']           = 1
    expectation['circumstances'] = 1
    expectation['of']            = 1
    expectation['personal']      = 1
    expectation['injury']        = 1
    expectation['accidents']     = 1
    expectation['in']            = 1
    expectation['gb']            = 1
    expectation['from']          = 1
    expectation['2005']          = 1

    actual = Metrics::RichnessOfInformation.term_frequency(notes)
    expect(actual).to eq(expectation)
  end

  it "computes the document frequency: words mapped to documents" do

    record1 = {:id => '1',
               :notes => 'Annual regional household income news.',
               :resources => [{:description => 'PDF'},
                              {:description => 'XLS'},
                              {:description => 'DOC'}]}
    record2 = {:id => '2',
               :notes => 'Number of people registered to vote in elections.',
               :resources => [{:description => 'PDF'}]}

    expectation = Hash.new
    expectation['annual']     = ['1']
    expectation['regional']   = ['1']
    expectation['household']  = ['1']
    expectation['income']     = ['1']
    expectation['news']       = ['1']
    expectation['pdf']        = ['1', '2']
    expectation['xls']        = ['1']
    expectation['doc']        = ['1']
    expectation['number']     = ['2']
    expectation['of']         = ['2']
    expectation['people']     = ['2']
    expectation['registered'] = ['2']
    expectation['to']         = ['2']
    expectation['vote']       = ['2']
    expectation['in']         = ['2']
    expectation['elections']  = ['2']

    metadata = [record1, record2]
    metric = Metrics::RichnessOfInformation.new(metadata)

    expect(metric.document_numbers).to be(6.0)
    expect(metric.document_frequency).to eq(expectation)
  end

  it "#value" do
    data = { :a => { :b => { :c => 3 }}}
    field = "a.b.c"
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to be(3)

    data = { :a => 5 }
    field = "a"
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to be(5)

    data = { :a => [{ :b => 3 }, { :b => 5 }, { :b => 7 }] }
    field = "a.b"
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to eq([3, 5, 7])
  end

  it "averages the scores if multiple documents are involved" do

   many = {:notes => 'These files provide detailed road safety data '\
                     'about the circumstances of personal injury road '\
                     'accidents in GB from 2005',

           :resources => [{:description => 'Road Safety - Accidents 2005'},
                          {:description => 'Road Safety - Accidents 2006'},
                          {:description => 'Road Safety - Accidents 2007'},
                          {:description => 'Road Safety - Accidents 2008'}]}

    few = {:notes => 'These files provide detailed road safety data '\
                     'about the circumstances of personal injury road '\
                     'accidents in GB from 2005',

           :resources => [{:description => 'Road Safety - Accidents 2008'}]}

    metadata = [many, few]
    metric = Metrics::RichnessOfInformation.new(metadata)

    many_score = metric.compute(many)
    few_score = metric.compute(few)

    # multiple field entries should not sum up but averaged
    expect(many_score).not_to be > few_score
  end

  it "computes the Term Frequency Inverse Document Frequency (tf-idf)" do

    record1 = {:id => '1',
               :notes => 'Annual regional household income news.',
               :resources => [{:description => 'PDF'},
                              {:description => 'XLS'},
                              {:description => 'DOC'}]}
    record2 = {:id => '2',
               :notes => 'Number of people registered to vote in elections.',
               :resources => [{:description => 'PDF'}]}

    metadata = [record1, record2]
    metric = Metrics::RichnessOfInformation.new(metadata)

    tf_idf = metric.tf_idf(record1[:notes])

    # There are 6 documents, each word occurs only once (in the field itself),
    # there are 5 words, hence ([Math.log(6 / 1)] * 5).sum / 5 == Math.log(6).
    expect(tf_idf).to be(Math.log(6))

  end

end
