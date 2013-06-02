require 'spec_helper'

describe Metrics::Completeness do

  describe "#completed?" do

    subject { Metrics::Completeness.new(Hash.new) }

    it { expect(subject.completed?(nil)).to be_false }
    it { expect(subject.completed?([])).to be_false }
    it { expect(subject.completed?({})).to be_false }
    it { expect(subject.completed?('')).to be_false }

    it { expect(subject.completed?(3)).to be_true }
    it { expect(subject.completed?('x')).to be_true }
    it { expect(subject.completed?([3])).to be_true }
    it { expect(subject.completed?({:x => 3})).to be_true }
  end

  it "counts the number of total fields and fields with a non-null value" do

    data = { :author => 'Donald E. Knuth',
             :title => 'The Art of Computer Programming, Volume 1',
             :subtitle => 'Fundamental Algorithms',
             :language => 'English' }

    schema = { :type       => 'object',
               :properties => { :author    => { :type => 'string'  },
                                :title     => { :type => 'string'  },
                                :subtitle  => { :type => 'string'  },
                                :publisher => { :type => 'string'  },
                                :language  => { :type => 'string'  },
                                :pages     => { :type => 'integer' }}}

    metric = Metrics::Completeness.new schema
    metric.compute data, schema
    expect(metric.fields).to be(6)
    expect(metric.fields_completed).to be(4)
    expect(metric.score).to be(4.0 / 6.0)
  end

  resources_schema = {:type => 'object',
                      :properties => {:description => {:type => 'string'},
                                      :format      => {:type => 'string'},
                                      :hash        => {:type => 'string'}}}
  schema = { :type       => 'object',
             :properties => {:title      => {:type => 'string' },
                             :author     => {:type => 'string' },
                             :resources  => {:type => 'array',
                                             :items => resources_schema}}}
    
  it "averages the score of records with multiple subfields" do

    record1 = { :title     => 'Farm Rents',
                :author    => 'Department for Environment and Food',
                :resources => [{:description => '2007',
                                :format      => 'PDF',
                                :hash        => ''},
                               {:description => '2008',
                                :format      => 'PDF',
                                :hash        => ''},
                               {:description => '2009',
                                :format      => 'PDF',
                                :hash        => ''}]}

    record2 = { :title     => 'Farm Rents',
                :author    => 'Department for Environment and Food',
                :resources => [{:description => '2007',
                                :format      => 'PDF',
                                :hash        => ''}]}

    metric = Metrics::Completeness.new schema
    score1 = metric.compute(record1, schema)

    metric = Metrics::Completeness.new schema
    score2 = metric.compute(record2, schema)

    expect(score1).to be < 1.0
    expect(score2).to be < 1.0
    expect(score2).to eq score1

  end

  it "takes the number of subfields into account" do

    record1 = { :title     => 'Farm Rents',
                :author    => 'Department for Environment and Food',
                :resources => [{:description => '2007',
                                :format      => '',
                                :hash        => ''}]}

    record2 = { :title     => 'Farm Rents',
                :author    => 'Department for Environment and Food',
                :resources => []}

    record3 = { :title     => 'Farm Rents',
                :author    => 'Department for Environment and Food',
                :resources => [{:description => '',
                                :format      => '',
                                :hash        => ''}]}


    metric = Metrics::Completeness.new
    score1 = metric.compute(record1, schema)

    metric = Metrics::Completeness.new
    score2 = metric.compute(record2, schema)

    metric = Metrics::Completeness.new
    score3 = metric.compute(record3, schema)

    expect(score1).to be > score1
    expect(score2).to be   score3

  end
end
