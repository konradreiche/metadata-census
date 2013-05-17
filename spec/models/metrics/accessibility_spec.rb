require 'spec_helper'

describe Metrics::Accessibility do

  it "should split a given text into its words" do
    
    text = "Estimates of average farm rent prices by farm type."
    expectations = ['Estimates', 'of', 'average', 'farm', 'rent', 'prices',
                    'by', 'farm', 'type']

    words = Metrics::Accessibility.split_to_words(text)
    words.should match_array expectations

    words = Metrics::Accessibility.split_to_words("")
    words.should match_array []

    words = Metrics::Accessibility.split_to_words("Estimates")
    words.should match_array ['Estimates']

  end

  it "should split a given text into its sentences" do

    text = "The Historic Landfill dataset was created to help fulfil our "
           "statutory responsibility to Local Planning Authorities by "
           "supplying information on the risks posed by landfill sites "
           "for development within 250m. The data is the most "
           "comprehensive and consistent national historic landfill "
           "dataset and defines the location of, and provides specific "
           "attributes for, known historic (closed) landfill sites, i.e. "
           "sites where there is no PPC permit or waste management "
           "licence currently in force. This includes sites that existed "
           "before the waste licensing regime and sites that have been "
           "licensed in the past but where this licence has been revoked, "
           "ceased to exist or surrendered and a certificate of "
           "completion has been issued."

    sentence1 = "The Historic Landfill dataset was created to help fulfil"
                "our statutory responsibility to Local Planning "
                "Authorities by supplying information on the risks posed "
                "by landfill sites for development within 250m."

    sentence2 = "The data is the most comprehensive and consistent national "
                "historic landfill dataset and defines the location of,"

    sentence3 = "and provides specific attributes for, known historic (closed)"
                "landfill sites, i.e. sites where there is no PPC permit or"
                "waste management licence currently in force."
                
    sentence4 = "This includes sites that existed before the "
                "waste licensing regime and sites that have been licensed"
                "in the past but where this licence has been revoked,"

    sentence5 = "ceased to exist or surrendered and a certificate of "
                "completion has been issued."

    sentences = Metrics::Accessibility.split_into_sentences(text)
    sentences.should match_array [sentence1, sentence2, sentence3,
                                  sentence4, sentence5]
  end
end
