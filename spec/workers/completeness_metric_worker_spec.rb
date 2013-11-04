require 'spec_helper'
require 'sidekiq/testing/inline'

describe CompletenessMetricWorker do

  describe "#perform" do
    before(:each) do
      repository = FactoryGirl.create(:repository)
      snapshot = FactoryGirl.create(:snapshot)
      metadata = FactoryGirl.create(:metadata_record)

      repository.snapshots << snapshot
      snapshot.metadata_records << metadata

      repository.save!
      snapshot.save!
    end

    it "performs a computation" do
      id = FactoryGirl.build(:repository).id
      date = FactoryGirl.build(:snapshot).date
      CompletenessMetricWorker.perform_async(id, date, :completeness)

      snapshot = Repository.all.first.snapshots.first
      score = snapshot.score

      document_score = snapshot.metadata_records.first.score
      completeness_score = snapshot.completeness['average']
      analysis = snapshot.completeness['analysis']

      expect(score.finite?).to be_true
      expect(score).to be < 1.0

      expect(score).to eq(completeness_score)
      expect(completeness_score.finite?).to be_true
      expect(completeness_score).to be < 1.0

      expect(document_score.finite?).to be_true
      expect(document_score).to eq(completeness_score)

      expect(analysis.keys.all? { |key| key.is_a?(String) }).to be_true
      expect(analysis.values.all? { |value| value.is_a?(Fixnum) }).to be_true
    end
  end

end
