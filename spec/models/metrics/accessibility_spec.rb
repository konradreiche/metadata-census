require 'spec_helper'

describe Metrics::Accessibility do

  it "should split a given text into its words" do
    text = "Estimates of average farm rent prices by farm type."
    expectations = ['Estimates', 'of', 'average', 'farm', 'rent', 'prices',
                    'by', 'farm', 'type']

    words = Metrics::Accessibility.split_to_words(text)
    words.should match_array expectations
  end
  
end
