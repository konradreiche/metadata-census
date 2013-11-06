FactoryGirl.define do
  factory :repository do
    id        'example.com'
    url       'http://www.example.com'
    type      'CKAN'
    name      'Example Repository'
    latitude  0.0
    longitude 0.0
  end

  factory :snapshot do
    date Date.today
    repository
  end

  factory :metadata_record do
    snapshot
    record    {{ 'id' => 'd8e8fca2dc-0f896fd7cb-4cb0031ba2' }}
  end

  sequence :repositories do |i|
    factory :repository do
      id        "example-#{i}.com"
      url       "http://www.example-#{i}.com"
      type      'CKAN'
      name      "Example Repository #{i}"
      latitude  i.to_f
      longitude i.to_f
    end
  end

  sequence :snapshots do
    factory :snapshot do |i|
      date Date.new(2013, 1, i)
    end
  end
end
