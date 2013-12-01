module Aggregator
  class Snapshot

    def self.aggregate(repositories)
      init = Hash.new { |hash, key| hash[key] = Hash.new }

      repositories.each_with_object(init) do |repository, result|
        repository.snapshots.to_a.each_with_object(init) do |snapshot, result|
          count = snapshot.metadata_records.count
          result[repository][snapshot][:metadata_count] = count
        end
      end
    end

  end
end
