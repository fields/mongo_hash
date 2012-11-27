require 'minitest/autorun'
require 'mongo'
require 'mongo_hash'

class TestMongoHash < MiniTest::Unit::TestCase
  # new empty mongohash
  # new _id mongohash
  # mongohash find query
  # mongohash save new record

  # mongohash find query with subkey

  # mongohash save modified record with no keychanges
  # mongohash save modified record with 1 keychange
  # mongohash save modified record with >1 keychange
  # mongohash save modified record with deletions
  # mongohash save modified record with subkey

  def setup
    db = Mongo::Connection.new('localhost').db('mongo_hash_test', :safe => true)
    @collection = db.collection('test')
    @collection.drop
  end

  def test_new_mongo_hash
    m = MongoHash.find(@collection)
    assert_equal m, []
    m = MongoHash.find_or_create(@collection, {"testkey" => 1}).first
    assert_equal m, {}
    m['testkey'] = 1
    m.save
    n = MongoHash.find_or_create(@collection, {"testkey" => 1}).first
    assert_equal m, n
    refute_equal m, {}
    m.destroy
    n = MongoHash.find_or_create(@collection, {"testkey" => 1}).first
    assert_equal n, {}
  end
  
  def test_subkey_hash
    m = MongoHash.new(@collection)
    assert_equal m, {}
    m['testkey'] = 1
    m['testsubkey'] = {"snoosnoo" => {"deathby" => true}}
    m.save
    n = MongoHash.find_or_create(@collection, {"testkey" => 1}, "testsubkey").first
    assert_equal m['testsubkey'], n['testsubkey']
    refute_equal n, m
    m.destroy    
  end
end