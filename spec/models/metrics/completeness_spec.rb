require 'spec_helper'

describe Metrics::Completeness do

  describe "#completed?" do

    subject do 
      metric = Metrics::Completeness.instance
      metric.configure(Hash.new)
    end

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

    data = { 'author' => 'Donald E. Knuth',
             'title' => 'The Art of Computer Programming, Volume 1',
             'subtitle' => 'Fundamental Algorithms',
             'language' => 'English' }

    schema = { 'type'       => 'object',
               'properties' => { 'author'   => { 'type' => 'string'  },
                                'title'     => { 'type' => 'string'  },
                                'subtitle'  => { 'type' => 'string'  },
                                'publisher' => { 'type' => 'string'  },
                                'language'  => { 'type' => 'string'  },
                                'pages'     => { 'type' => 'integer' }}}

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score, _ = metric.compute(data)
    
    expect(metric.fields).to be(6)
    expect(metric.fields_completed).to be(4)
    expect(score).to be(4.0 / 6.0)
  end

  resources_schema = {'type' => 'object',
                      'properties' => {'description' => {'type' => 'string'},
                                      'format'      => {'type' => 'string'},
                                      'hash'        => {'type' => 'string'}}}
  schema = { 'type'       => 'object',
             'properties' => {'title'      => {'type' => 'string' },
                             'author'     => {'type' => 'string' },
                             'resources'  => {'type' => 'array',
                                             'items' => resources_schema}}}
    
  it "averages the score of records with multiple subfields" do

    record1 = { 'title'     => 'Farm Rents',
                'author'    => 'Department for Environment and Food',
                'resources' => [{'description' => '2007',
                                'format'      => 'PDF',
                                'hash'        => ''},
                               {'description' => '2008',
                                'format'      => 'PDF',
                                'hash'        => ''},
                               {'description' => '2009',
                                'format'      => 'PDF',
                                'hash'        => ''}]}

    record2 = { 'title'     => 'Farm Rents',
                'author'    => 'Department for Environment and Food',
                'resources' => [{'description' => '2007',
                                'format'      => 'PDF',
                                'hash'        => ''}]}

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score1, _ = metric.compute(record1)

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score2, _ = metric.compute(record2)

    expect(score1).to be < 1.0
    expect(score2).to be < 1.0
    expect(score2).to eq score1

  end

  it "counts only subfields if a field has a complex schema" do

    record1 = { 'title'     => 'Farm Rents',
                'author'    => 'Department for Environment and Food',
                'resources' => [{'description' => '2007',
                                'format'      => '',
                                'hash'        => ''}]}

    record2 = { 'title'     => 'Farm Rents',
                'author'    => 'Department for Environment and Food',
                'resources' => []}

    record3 = { 'title'     => 'Farm Rents',
                'author'    => 'Department for Environment and Food',
                'resources' => [{'description' => '',
                                'format'      => '',
                                'hash'        => ''}]}


    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score1, _ = metric.compute(record1)

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score2, _ = metric.compute(record2)

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    score3, _ = metric.compute(record3)

    expect(score1).to be > score3
    expect(score2).to be   score3
  end

  it "tracks the count of completed fields" do

    record = { 'title'     => 'Farm Rents',
               'author'    => 'Department for Environment and Food',
               'resources' => [{ 'description' => '2007',
                                 'hash'        => '' }]}

    metric = Metrics::Completeness.instance
    metric.configure(schema)
    _, analysis = metric.compute(record)

    expect(analysis).to eq({ 'title' => 1,
                             'author' => 1,
                             'resources' => { 'description' => 1,
                                              'format' => 0 ,
                                              'hash' => 0} })
  end

end
