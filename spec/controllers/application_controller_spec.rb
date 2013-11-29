require 'spec_helper'

describe ApplicationController do

  describe "#forge_parameters" do

    it "works for parameters: repository" do
      repository = FactoryGirl.create(:repository)

      parameters = subject.send(:forge_parameters, repository)
      expect(parameters).to eq({ id: repository.id })
    end

    it "works for parameters: repository, snapshot" do
      repository = FactoryGirl.create(:repository, :with_snapshots)
      snapshot = repository.snapshots.first

      parameters = subject.send(:forge_parameters, repository, snapshot)
      expectations = { repository_id: repository.id, id: snapshot.date.to_s }
      expect(parameters).to eq(expectations)
    end

    it "works for parameters: repository, snapshot, metric" do
      repository = FactoryGirl.create(:repository, :with_snapshots)
      snapshot = repository.snapshots.first
      metric = :completeness

      parameters = subject.send(:forge_parameters, repository, snapshot, metric)

      expectations = { repository_id: repository.id,
                       snapshot_id: snapshot.date.to_s,
                       id: metric }

      expect(parameters).to eq(expectations)
    end
  end
end
