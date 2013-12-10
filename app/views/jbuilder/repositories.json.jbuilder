json.repositories @repositories.keys do |repository|
  json.id        repository.id
  json.longitude repository.longitude
  json.latitude  repository.latitude
  json.score     @repositories[repository]['score']
end
