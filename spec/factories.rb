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

  factory :repositories, class: Repository do
    id
    url
    name
    type 'CKAN'
    latitude
    longitude
  end

  # Snapshot Factory
  factory :snapshots, class: Snapshot do
    date 
  end

  # Metadata Record Factory
  factory :metadata_records, class: MetadataRecord do
    record
  end

  # Repository Trait
  trait :with_snapshots do
    ignore do
      snapshots_count 3
    end

    after :create do |repository, evaluator|
      entities = :snapshots
      count = evaluator.snapshots_count
      FactoryGirl.create_list(entities, count, repository: repository)
    end
  end

  trait :with_metadata do
    ignore { metadata_count 10 }

    after :create do |repository, evaluator|
      entities = :metadata_records
      count = evaluator.metadata_count
      repository.snapshots.each do |snapshot|
        FactoryGirl.create_list(entities, count, snapshot: snapshot)
      end
    end
  end

end
