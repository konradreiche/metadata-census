require 'spec_helper'

describe Completeness do
  it "counts the number of total fields and fields with a non-null value" do

    data = { 'author' => 'Donald E. Knuth',
             'title' => 'The Art of Computer Programming, Volume 1',
             'subtitle' => 'Fundamental Algorithms',
             'language' => 'English' }

    schema = { 'type' => 'object',
               'properties' => { 'author'    => { 'type' => 'string'  },
                                 'title'     => { 'type' => 'string'  },
                                 'subtitle'  => { 'type' => 'string'  },
                                 'publisher' => { 'type' => 'string'  },
                                 'language'  => { 'type' => 'string'  },
                                 'pages'     => { 'type' => 'integer' } } }

    metric = Completeness.new
    metric.compute data, schema
    expect(metric.fields).to be 6
    expect(metric.fields_completed).to be 4
    expect(metric.score).to be 4.0 / 6.0
  end
end
