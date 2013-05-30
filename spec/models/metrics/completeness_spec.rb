require 'spec_helper'

describe Metrics::Completeness do
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

    metric = Metrics::Completeness.new
    metric.compute data, schema
    expect(metric.fields).to be(6)
    expect(metric.fields_completed).to be(4)
    expect(metric.score).to be(4.0 / 6.0)
  end

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

    resources_schema = {:type => 'object',
                        :properties => {:description => {:type => 'string'},
                                        :format      => {:type => 'string'},
                                        :hash        => {:type => 'string'}}}
    schema = { :type       => 'object',
               :properties => {:title      => {:type => 'string' },
                               :author     => {:type => 'string' },
                               :resources  => {:type => 'array',
                                               :items => resources_schema}}}

    metric = Metrics::Completeness.new
    score = metric.compute(record1, schema)
    expect(score).to be < 1.0
  end
end
