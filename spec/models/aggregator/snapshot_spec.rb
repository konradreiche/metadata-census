require 'spec_helper'

describe Aggregator::Snapshot do
  describe "::aggregate" do
    it "builds snapshot data" do
      traits = [:with_snapshots, :with_metadata]
      counts = { snapshots_count: 2, metadata_count: 10 }

      repositories = FactoryGirl.create_list(:repository, 3, *traits, counts)
      snapshots = repositories.map(&:snapshots)

      expected_count = { metadata_count: 10 }

      # TODO: use when a new RSpec version hasbeen released
      #
      # expectation = { repositories[0] => { snapshots[0][0] => expected_count,
      #                                      snapshots[0][1] => expected_count },
      #
      #                 repositories[1] => { snapshots[1][0] => expected_count,
      #                                      snapshots[1][1] => expected_count },
      #
      #                 repositories[2] => { snapshots[2][0] => expected_count,
      #                                      snapshots[2][1] => expected_count } }

      result = Aggregator::Snapshot.aggregate(repository)

      expect(result[repositories[0]][snapshots[0][0]]).to eq(expected_count)
      expect(result[repositories[0]][snapshots[0][1]]).to eq(expected_count)

      expect(result[repositories[1]][snapshots[1][0]]).to eq(expected_count)
      expect(result[repositories[1]][snapshots[1][1]]).to eq(expected_count)

      expect(result[repositories[2]][snapshots[2][0]]).to eq(expected_count)
      expect(result[repositories[2]][snapshots[2][1]]).to eq(expected_count)
    end
  end
end
