require 'spec_helper'

describe MetricsWorker do

  describe '.symbolize_keys' do

    context 'applied on a simple hash' do
      grades = { "Jane Doe" => 10, "Jim Doe" => 6 }
      subject { MetricsWorker.symbolize_keys(grades) }

      it { should have_key(:"Jane Doe") }
      it { should have_key(:"Jim Doe") }
      it { should have_value(10) }
      it { should have_value(6) }
    end

    context 'applied on a nested hash' do
      document = { :options => { "font_size" => 10, "font_family" => "Arial" } }
      subject { MetricsWorker.symbolize_keys(document)[:options] }
      it { should have_key(:font_size) }
      it { should have_key(:font_family) }
      it { should have_value(10) }
      it { should have_value("Arial") }
    end

    context 'applied on a hash with an array' do
      book = { :title => 'Open Government',
               :authors => [{ "name" => 'Daniel Lathrop' },
                            { "name" => 'Laurel R.T. Ruma' }]}
      subject { MetricsWorker.symbolize_keys(book)[:authors] }
      its([0]) { should have_key(:name) }
      its([0]) { should_not have_key("name") }
      its([1]) { should have_key(:name) }
      its([1]) { should_not have_key("name") }
    end

  end
end
