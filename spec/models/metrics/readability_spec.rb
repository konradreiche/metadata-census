require 'spec_helper'

describe Metrics::Readability do

  it "should split a given text into its words" do
    
    text = "Estimates of average farm rent prices by farm type."
    expectations = ['Estimates', 'of', 'average', 'farm', 'rent', 'prices',
                    'by', 'farm', 'type']
 
    words = Metrics::Metric.instance.words(text)
    words.should match_array expectations

    words = Metrics::Metric.instance.words("")
    words.should match_array []

    words = Metrics::Metric.instance.words("Estimates")
    words.should match_array ['Estimates']

  end

  it "should split a given text into its sentences" do

    accessibility = Metrics::Readability.instance
    accessibility.configure('en_us')
    
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

    sentences = accessibility.split_sentences(text)
    sentences.should match_array [sentence1, sentence2, sentence3]
    count = accessibility.sentences(text)
    expect(count).to be(3)

    sentences = accessibility.split_sentences("")
    sentences.should match_array []
    count = accessibility.sentences("")
    expect(count).to be(0)

    sentences = accessibility.split_sentences("The Historic Landfill")
    sentences.should match_array ["The Historic Landfill"]
    count = accessibility.sentences("The Historic Landfill")
    expect(count).to be(1)
  end

  it "should hyphenate a word into its syllables" do

    accessibility = Metrics::Readability.instance
    accessibility.configure('en_us')

    syllables = accessibility.hyphenate("representation")
    syllables.should match_array [3, 5, 8, 10]
    count = accessibility.syllables("representation")
    expect(count).to be(5)

    syllables = accessibility.hyphenate("The")
    syllables.should match_array []
    count = accessibility.syllables("The")
    expect(count).to be(1)

    syllables = accessibility.hyphenate("i")
    syllables.should match_array []
    count = accessibility.syllables("i")
    expect(count).to be(1)

    syllables = accessibility.hyphenate("")
    syllables.should be_nil
    count = accessibility.syllables("")
    expect(count).to be(0)
  end

  it "should compute the Flesch Reading Ease" do

    accessibility = Metrics::Readability.instance
    accessibility.configure('en_us')

    text = "The Historic Landfill dataset was created to help fulfil our "\
           "statutory responsibility to Local Planning Authorities by "\
           "supplying information on the risks posed by landfill sites "\
           "for development within 250m. The data is the most "\
           "comprehensive and consistent national historic landfill "\
           "dataset and defines the location of, and provides specific "\
           "attributes for, known historic (closed) landfill sites, i.e. "\
           "sites where there is no PPC permit or waste management "\
           "licence currently in force."

    words = Metrics::Metric.instance.words(text)
    expect(words.length).to be(71)

    sentences = accessibility.sentences(text).to_f
    expect(sentences).to be(2.0)

    syllables = Metrics::Metric.instance.words(text).map do |word|
      accessibility.syllables(word)
    end.sum.to_f
    expect(syllables).to be(133.0)

    average_sentence_length = words.length / sentences
    average_syllables_per_word = syllables / words.length

    expect(average_sentence_length).to be(35.5)
    expect(average_syllables_per_word.round(2)).to be(1.87)

    score = accessibility.flesch_reading_ease(text)
    expect(score.round(2)).to be(0.87)

    score, analysis = accessibility.compute({ 'notes' => text })

    expect(analysis).to eq([{ score: score, field: ['notes'] }])
    expect(score.round(2)).to be(0.87)

  end

end
