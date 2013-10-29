require 'spec_helper'

describe Admin::SnapshotsController do

  describe "POST create" do

    let(:repository) { FactoryGirl.create(:repository) }
    let(:file) { "spec/data/archives/example.com/2013-10-29-example.com.jl.gz" }

    subject { post "create", repository_id: repository.id, file: file }

    it "renders nothing" do
      expect(subject).to have_text(' ')
    end

    it "creates a new snapshot" do
      expect { subject }.to change { repository.reload.snapshots.count }.by(1)
    end

    it "creates the test snapshot" do
      post "create", repository_id: repository.id, file: file
      snapshot = repository.reload.snapshots.first
      expect(snapshot.date).to eq(Date.new(2013, 10, 29))
    end

    it "creates a new metadata record" do
      post "create", repository_id: repository.id, file: file
      snapshot = repository.reload.snapshots.first
      expect(snapshot.metadata_records.count).to be(1)
    end

    it "compiles statistics about the metadata record" do
      statistics = { "languages" => { "Unknown" => 1 },
                     "resources" => { "min" => 0,
                                      "avg" => 0.0,
                                      "max" => 0,
                                      "sum" => 0,
                                      "med" => 0 } }

      post "create", repository_id: repository.id, file: file
      snapshot = repository.reload.snapshots.first
      expect(snapshot.statistics).to eq(statistics)
    end
  end

end
