FactoryGirl.define do

  # Attributes
  sequence(:id)        { |i| "example-#{i}.com" }
  sequence(:url)       { |i| "http://www.example-#{i}.com" }
  sequence(:name)      { |i| "Example Repository #{i}" }
  sequence(:latitude)  { |i| i }
  sequence(:longitude) { |i| i }
  sequence(:date)      { |i| Date.parse('2014-01-01') + i }
  sequence(:record)    { |i| { 'id' => i.hash.to_s } }

  # Repository Factory
  factory :repository do
    id        'example.com'
    url       'http://www.example.com'
    name      'Example Repository'
    type      'CKAN'
    latitude  0.0
    longitude 0.0
  end

  sequence :repositories do
    id        'example.com'
    url       'http://www.example.com'
    name      'Example Repository'
    type      'CKAN'
    latitude  0.0
    longitude 0.0
  end

  # Snapshot Factory
  factory :snapshot do
    date 
  end

  # Metadata Record Factory
  factory :metadata_record do
    record
  end

  # Repository Trait
  trait :with_snapshots do
    ignore do
      snapshots_count 3
    end

    after :create do |repository, evaluator|
      entity = :snapshot
      count = evaluator.snapshots_count
      FactoryGirl.create_list(entity, count, repository: repository)
    end
  end

  trait :with_metadata do
    ignore { metadata_count 10 }

    after :create do |repository, evaluator|
      entity = :metadata_record
      count = evaluator.metadata_count
      repository.snapshots.each do |snapshot|
        FactoryGirl.create_list(entity, count, snapshot: snapshot)
      end
    end
  end

end
