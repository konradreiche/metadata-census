require 'spec_helper'

describe ApplicationController do

  describe "#forge_parameters" do

    it "works for parameters: repository" do
      repository = FactoryGirl.create(:repository, id: 'example.com')
      parameters = subject.send(:forge_parameters, repository)
      expect(parameters).to eq({id: 'example.com'})
    end

    it "works for parameters: repository, snapshot" do
      repository = FactoryGirl.create(:repository, id: 'example.com')
      snapshot = FactoryGirl.create(:snapshot, date: Date.new(2013, 11, 7))

      parameters = subject.send(:forge_parameters, repository, snapshot)
      expectations = { repository_id: 'example.com', id: '2013-11-07' }
      expect(parameters).to eq(expectations)
    end

    it "works for parameters: repository, snapshot, metric" do
      repository = FactoryGirl.create(:repository, id: 'example.com')
      snapshot = FactoryGirl.create(:snapshot, date: Date.new(2013, 11, 7))
      metric = :completeness

      parameters = subject.send(:forge_parameters, repository, snapshot, metric)
      expectations = { repository_id: 'example.com',
                       snapshot_id: '2013-11-07',
                       id: metric }

      expect(parameters).to eq(expectations)
    end
  end
end
