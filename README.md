Mongo Hash
==========
MongoHash is a simple schema-less persistence layer for easily saving and retrieving documents from a mongodb database. Once a document has been created or retrieved, it can be dealt with in most ways as a normal ruby hash, and then easily saved back to the database.

## Installation
	gem install mongo_hash

## Usage

Basic usage is simple:

	require 'mongo'
	require 'mongo_hash'
	db = Mongo::Connection.new('localhost').db('mongo_hash_test', :safe => true)
    @collection = db.collection('test')
	mh = MongoHash.new(@collection)
	
Build up a hash and save it

	mh = MongoHash.new(@collection)
	mh['testkey'] = 1
	mh['somekeys'] = {"podsix" => "jerks", "stimutacs" => "onemore"}
	mh.save
	
Find all:

	> MongoHash.find(@collection)
	=> [{"testkey"=>1, "somekeys"=>{"podsix"=>"jerks", "stimutacs"=>"onemore"}, "created_at"=>1354035712}]
 
Find specific:
	
	> MongoHash.find(@collection, {"testkey" => 1})
	=> [{"testkey"=>1, "somekeys"=>{"podsix"=>"jerks", "stimutacs"=>"onemore"}, "created_at"=>1354035712}]
	
Find or create:

	> mh = MongoHash.find(@collection, {"testkey" => 1}).first
 	=> {"testkey"=>1, "somekeys"=>{"podsix"=>"jerks", "stimutacs"=>"onemore"}, "created_at"=>1354035712} 
	> mh = MongoHash.find(@collection, {"testkey" => 0}).first
 	=> nil
 	
Add or delete keys:

	> mh = MongoHash.find(@collection, {"testkey" => 1}).first
 	=> {"testkey"=>1, "somekeys"=>{"podsix"=>"jerks", "stimutacs"=>"onemore"}, "created_at"=>1354035712} 
	> mh['somemorekeys'] = {"justthefacts" => "please"}
 	=> {"justthefacts"=>"please"} 
	> mh['evenmorekeys'] = {"petshopboys" => "please"}
 	=> {"petshopboys"=>"please"} 
	> mh.delete('somekeys')
 	=> {"podsix"=>"jerks", "stimutacs"=>"onemore"} 
	> mh
 	=> {"testkey"=>1, "created_at"=>1354035712, "somemorekeys"=>{"justthefacts"=>"please"}, "evenmorekeys"=>{"petshopboys"=>"please"}} 
	> mh.save
 	=> {"updatedExisting"=>true, "n"=>1, "connectionId"=>69, "err"=>nil, "ok"=>1.0}
 	
Retrieve and update just a subkey hash (does not touch the rest of the record):

	> mh = MongoHash.find(@collection, {"testkey" => 1}, "somemorekeys").first
	=> {"somemorekeys"=>{"justthefacts"=>"please"}} 
	> mh['somemorekeys']['peas'] = "please"
 	=> "please" 
	> mh
 	=> {"somemorekeys"=>{"justthefacts"=>"please", "peas"=>"please"}}
 	=> {"updatedExisting"=>true, "n"=>1, "connectionId"=>75, "err"=>nil, "ok"=>1.0}
	> mh = MongoHash.find(@collection, {"testkey" => 1}).first
	=> {"created_at"=>1354036563, "evenmorekeys"=>{"petshopboys"=>"please"}, "somemorekeys"=>{"justthefacts"=>"please", "peas"=>"please"}, "testkey"=>1}
	

# Ruby Version
MongoHash has been tested with ruby 1.9.3 and ree 1.8.7.

# Contributors
+ [Adam Fields](https://github.com/fields)