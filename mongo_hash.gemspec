Gem::Specification.new do |s|
  s.name        = 'mongo_hash'
  s.version     = '0.1.0'
  s.date        = '2012-11-11'
  s.summary     = "MongoHash"
  s.description = "A simple front-end for mongodb persistence for ruby hashes"
  s.authors     = ["Adam Fields"]
  s.email       = 'adam@morningside-analytics.com'
  s.files       = ["lib/mongo_hash.rb"]
  s.homepage    =
    'http://rubygems.org/gems/mongo_hash'
  s.add_dependency('mongo')
  s.requirements << 'Mongo Gem'
end