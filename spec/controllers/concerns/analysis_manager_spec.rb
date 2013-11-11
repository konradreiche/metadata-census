require 'spec_helper'

describe AnalysisManager do

  class AnonymousController < ApplicationController
    include AnalysisManager

    def initialize(metric=:test_metric)
      @metric = metric
      @snapshot = Snapshot.new
    end

    # Stubbing gon
    #
    def gon
      OpenStruct.new
    end

  end

  describe "::analyze" do

    subject { AnonymousController.new }

    before(:all) do
      AnalysisManager.const_set(:ANALYZER_PATH, 'spec/models/analyzer')
      load 'spec/models/analyzer/test_metric.rb'
    end

    it "constantizes the test metric analyzer" do
      subject.send(:analyze)
      result = subject.instance_variable_get('@analysis')

      expectations = { scores: [], details: 'test_analysis'}
      expect(result).to eq(expectations)
    end

    it "fallbacks to the generic analyzer" do
      controller = AnonymousController.new(:alternative_metric)
      controller.send(:analyze)

      result = controller.instance_variable_get('@analysis')
      expect(result).to be_nil
    end

  end
end
