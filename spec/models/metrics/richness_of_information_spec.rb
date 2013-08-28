require 'spec_helper'

# TODO:
# - write test if there are null entries
# - write test if there is a semi-empty string " "

describe Metrics::RichnessOfInformation do

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
    expectation['annual']     = [['1', :notes]]
    expectation['regional']   = [['1', :notes]]
    expectation['household']  = [['1', :notes]]
    expectation['income']     = [['1', :notes]]
    expectation['news']       = [['1', :notes]]
    expectation['pdf']        = [['1', :resources, 0, :description],
                                 ['2', :resources, 0, :description]]

    expectation['xls']        = [['1', :resources, 1, :description]]
    expectation['doc']        = [['1', :resources, 2, :description]]
    expectation['number']     = [['2', :notes]]
    expectation['of']         = [['2', :notes]]
    expectation['people']     = [['2', :notes]]
    expectation['registered'] = [['2', :notes]]
    expectation['to']         = [['2', :notes]]
    expectation['vote']       = [['2', :notes]]
    expectation['in']         = [['2', :notes]]
    expectation['elections']  = [['2', :notes]]

    metadata = [record1, record2]
    metric = Metrics::RichnessOfInformation.new(metadata)

    expect(metric.document_numbers).to be(6.0)
    expect(metric.document_frequency).to eq(expectation)
  end

  it "computes the occurence of a categorical value" do
    metadata = []
    metadata << {:id => '1', :tags => ['health', 'children'] }
    metadata << {:id => '2', :tags => ['health', 'population'] }
    metadata << {:id => '3', :tags => ['education', 'children'] }
    metadata << {:id => '4', :tags => ['business', 'employment'] }

    metric = Metrics::RichnessOfInformation.new(metadata)

    expect(metric.categorical_frequency[[:tags]]['health']).to be(2)
    expect(metric.categorical_frequency[[:tags]]['children']).to be(2)
    expect(metric.categorical_frequency[[:tags]]['population']).to be(1)
    expect(metric.categorical_frequency[[:tags]]['education']).to be(1)
    expect(metric.categorical_frequency[[:tags]]['business']).to be(1)
    expect(metric.categorical_frequency[[:tags]]['employment']).to be(1)
  end

  it "computes the negative probability of a categorical value to occur" do
    metadata = []
    metadata << {:id => '1', :tags => ['health', 'children'] }
    metadata << {:id => '2', :tags => ['health', 'population'] }
    metadata << {:id => '3', :tags => ['education', 'children'] }
    metadata << {:id => '4', :tags => ['business', 'employment'] }

    metric = Metrics::RichnessOfInformation.new(metadata)

    health = metric.richness_of_information('health', :category, [:tags])
    children = metric.richness_of_information('children', :category, [:tags]) 
    business = metric.richness_of_information('business', :category, [:tags]) 
    education = metric.richness_of_information('education', :category, [:tags]) 
    population = metric.richness_of_information('population', :category, [:tags]) 
    employment = metric.richness_of_information('employment', :category, [:tags]) 

    expect(health).to be(- Math.log(0.25))
    expect(children).to be(- Math.log(0.25))
    expect(business).to be(- Math.log(0.125))
    expect(education).to be(- Math.log(0.125))
    expect(population).to be(- Math.log(0.125))
    expect(employment).to be(- Math.log(0.125))
  end

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

    many_score = metric.compute(many).first
    few_score = metric.compute(few).first

    # multiple field entries should not sum up but averaged
    expect(many_score).not_to be > few_score
  end

  it "computes the Term Frequency Inverse Document Frequency (tf-idf)" do

    record1 = {:id => '1',
               :notes => 'Annual regional household income news.',
               :resources => [{:description => 'Household Income - PDF'},
                              {:description => 'Household Income - XLS'},
                              {:description => 'Household Income - DOC'}]}
    record2 = {:id => '2',
               :notes => 'Number of people registered to vote in elections.',
               :resources => [{:description => 'PDF'}]}

    record3 = {:id => '3',
               :notes => nil,
               :resources => [{}]}

    metadata = [record1, record2, record3]
    metric = Metrics::RichnessOfInformation.new(metadata)

    tf_idf = metric.tf_idf(record1[:notes])

    # Total Documents    => 6
    # Words in Documents => 5
    #
    # 'annual'    Occurs => 1, Total => 1
    # 'regional'  Occurs => 1, Total => 1
    # 'household' Occurs => 1, Total => 4
    # 'income'    Occurs => 1, Total => 4
    # 'news'      Occurs => 1, Total => 1
    #
    #   sum [1 * log(6/1), 1 * log(6/1), 1 * log(6/4), 1 * log(6/4),
    #        1 * log(6/1)] / 5
    #
    # = sum [4 * log(6), 2 * log(1.5)] / 5
    #
    expect(tf_idf).to be((3 * Math.log(6) + 2 * Math.log(1.5)) / 5)

    tf_idf = metric.tf_idf(record2[:resources][0][:description])

    # Total Documents   => 6
    # Words in Document => 1
    #
    # 'PDF' Occurs => 1, Total => 2
    #
    #   sum [1 * log(6/2)] / 1
    # = log(3)
    #
    expect(tf_idf).to be(Math.log(3))

    tf_idf = metric.tf_idf(record1[:resources][0][:description])

    # Total Documents   => 6
    # Words in Document => 3
    #
    # 'household' Occurs => 1, Total => 4
    # 'income'    Occurs => 1, Total => 4
    # 'PDF'       Occurs => 1, Total => 2
    #
    #   sum [1 * log(6/4), 1 * log(6/4), 1 * log(6/2)] / 3
    # = sum [2 * Math.log(1.5), Math.log(3)] / 3
    #
    expect(tf_idf).to be((2 * Math.log(1.5) + Math.log(3)) / 3)

    # If there are no fields to assert a Richness of Information the score
    # should be zero.
    score = metric.compute(record3).first
    expect(score).to be(0.0)
  end

  it "#value" do
    data = { :a => { :b => { :c => 3 }}}
    field = [:a, :b, :c]
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to be(3)

    data = { :a => 5 }
    field = [:a]
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to be(5)

    data = { :a => [{ :b => 3 }, { :b => 5 }, { :b => 7 }] }
    field = [:a, :b]
    value = Metrics::RichnessOfInformation.value(data, field)
    expect(value).to eq([3, 5, 7])
  end


end
