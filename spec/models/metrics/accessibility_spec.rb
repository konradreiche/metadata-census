require 'spec_helper'

describe Metrics::Accessibility do


  it "should split a given text into its words" do
    
    text = "Estimates of average farm rent prices by farm type."
    expectations = ['Estimates', 'of', 'average', 'farm', 'rent', 'prices',
                    'by', 'farm', 'type']
    
    words = Metrics::Accessibility.split_to_words(text)
    words.should match_array expectations
    count = Metrics::Accessibility.words(text)
    expect(count).to be(9)

    words = Metrics::Accessibility.split_to_words("")
    words.should match_array []
    count = Metrics::Accessibility.words("")
    expect(count).to be(0)   

    words = Metrics::Accessibility.split_to_words("Estimates")
    words.should match_array ['Estimates']
    count = Metrics::Accessibility.words("Estimates")
    expect(count).to be(1)   

  end

  it "should split a given text into its sentences" do

    accessibility = Metrics::Accessibility.new 'en_us'
    
    text = "The Historic Landfill dataset was created to help fulfil our "\
           "statutory responsibility to Local Planning Authorities by "\
           "supplying information on the risks posed by landfill sites "\
           "for development within 250m. The data is the most "\
           "comprehensive and consistent national historic landfill "\
           "dataset and defines the location of, and provides specific "\
           "attributes for, known historic (closed) landfill sites, i.e. "\
           "sites where there is no PPC permit or waste management "\
           "licence currently in force. This includes sites that existed "\
           "before the waste licensing regime and sites that have been "\
           "licensed in the past but where this licence has been revoked, "\
           "ceased to exist or surrendered and a certificate of "\
           "completion has been issued."

    sentence1 = "The Historic Landfill dataset was created to help fulfil "\
                "our statutory responsibility to Local Planning "\
                "Authorities by supplying information on the risks posed "\
                "by landfill sites for development within 250m."\

    sentence2 = "The data is the most comprehensive and consistent national "\
                "historic landfill dataset and defines the location of, "\
                "and provides specific attributes for, known historic (closed) "\
                "landfill sites, i.e. sites where there is no PPC permit or "\
                "waste management licence currently in force."\
                
    sentence3 = "This includes sites that existed before the "\
                "waste licensing regime and sites that have been licensed "\
                "in the past but where this licence has been revoked, "\
                "ceased to exist or surrendered and a certificate of "\
                "completion has been issued."

    sentences = accessibility.split_into_sentences(text)
    sentences.should match_array [sentence1, sentence2, sentence3]
    count = accessibility.sentences(text)
    expect(count).to be(3)

    sentences = accessibility.split_into_sentences("")
    sentences.should match_array []
    count = accessibility.sentences("")
    expect(count).to be(0)

    sentences = accessibility.split_into_sentences("The Historic Landfill")
    sentences.should match_array ["The Historic Landfill"]
    count = accessibility.sentences("The Historic Landfill")
    expect(count).to be(1)
  end

  it "should hyphenate a word into its syllables" do

    accessibility = Metrics::Accessibility.new 'en_us'

    syllables = accessibility.hyphenate("Historic")
    syllables.should match_array ["His", "tor", "ic"]
    count = accessibility.syllables("Historic")
    expect(count).to be(3)

    syllables = accessibility.hyphenate("The")
    syllables.should match_array ["The"]
    count = accessibility.syllables("The")
    expect(count).to be(1)

    syllables = accessibility.hyphenate("")
    syllables.should match_array []
    count = accessibility.syllables("")
    expect(count).to be(0)

  end

end
