require 'spec_helper'

describe Metrics::RichnessOfInformation do

  it "computes the frequency of a word in a given text" do

    notes = 'These files provide detailed road safety data '\
            'about the circumstances of personal injury road '\
            'accidents in GB from 2005',

    expectation = Hash.new
    expectation['these']         = 1
    expectation['files']         = 1
    expectation['provide']       = 1
    expectation['detailed']      = 1
    expectation['road']          = 1
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
  end

  it "computes the Term Frequency-Inverse Document Frequency" do
    subject.compute(record1)
    expect(subject.score.round(5)).to be(1.70512)
  end

  it "averages the scores if multiple documents are involved" do

   big_record = {:notes => 'These files provide detailed road safety data '\
                            'about the circumstances of personal injury road '\
                            'accidents in GB from 2005',

                 :resources => [{:description => 'Road Safety - Accidents 2005'},
                                {:description => 'Road Safety - Accidents 2006'},
                                {:description => 'Road Safety - Accidents 2007'},
                                {:description => 'Road Safety - Accidents 2008'}]}

    small_record = {:notes => 'These files provide detailed road safety data '\
                              'about the circumstances of personal injury road '\
                              'accidents in GB from 2005',

                    :resources => [{:description => 'Road Safety - Accidents 2008'}]}

    metric = Metrics::RichnessOfInformation.new([small_record, big_record])
    small_record_score = metric.compute(small_record)
    big_record_score = metric.compute(big_record)

    # Multiple record entries should not sum up but averaged
    expect(big_record_score).not_to be > small_record_score
  end

end
