class MongoHash < Hash
  attr_accessor :collection
  attr_accessor :new_record
  attr_accessor :subkey
  attr_accessor :_id
  attr_accessor :query_hash
  attr_accessor :fields
  attr_accessor :dirty_keys
  attr_accessor :delete_keys


### figure out how to make this one method
  def get_options_specifier(subkey)
    if subkey == ""
      {}
    else
      {:fields => {'_id' => 1, subkey => 1}}
    end
  end

  def self.get_options_specifier(subkey)
    if subkey == ""
      {}
    else
      {:fields => {'_id' => 1, subkey => 1}}
    end
  end

  # Main find method to use for searching the mongo collection for a matching object
  #
  # @param [Mongo::Collection] the mongo collection object
  # @param [Hash] the query specifier, in standard mongodb syntax, optional
  # @param [String] the subkey attribute to base the return on, optional
  # @return [Array] the list of matching MongoHash objects from the collection
  
  def self.find(collection, query = {}, subkey = "")
    options_specifier = get_options_specifier(subkey)
    records = collection.find(query, options_specifier)
    return [] if records.nil? or records == [] or records.count == 0
    mhs = []
    records.each{|record|
      mhs << self.new(collection, record['_id'], record, subkey)
    }
    mhs
  end

  # Finds matching objects, or creates a blank one if not
  #
  # @todo Infer default values from the query specifier
  # @param [Mongo::Collection] the mongo collection object
  # @param [Hash] the query specifier, in standard mongodb syntax, optional
  # @param [String] the subkey attribute to base the return on, optional
  # @return [Array] the list of matching MongoHash objects from the collection, or an array with a blank MongoHash object if none found

  def self.find_or_create(collection, query = {}, subkey = "")
    result = self.find(collection, query, subkey)
    if result == []
      result = [self.new(collection)]
    else
      result
    end
  end

  # MongoHash.new creates a new blank object tied to the specified collection or retrieves a specific object
  #
  # @param [Mongo::Collection] the mongo collection object
  # @param [Object] the _id to query the collection for, optional
  # @param [Hash] the default value to prepopulate into the returned object, optional
  # @param [String] the subkey attribute to base the return on, optional
  # @return [MongoHash] a single MongoHash object tied to the specified collection

  def initialize(collection, _id = nil, default = {}, subkey = "")
    @subkey = subkey
    @collection = collection
    if _id.nil?
      @new_record = true
    else
      @_id = _id
      @new_record = false
    end
    @dirty_keys = []
    @delete_keys = []
#    super() {|h, k| h[k] = Hash.new()}
    super()
    if default == {}
#        puts default.inspect
#        puts _id
      unless @new_record
        options_specifier = self.get_options_specifier(subkey)
        default = collection.find({'_id' => _id}, options_specifier).first
      end
    end
    default.delete('_id')
    default.delete(:_id)    
    default.each{|k,v|
#      puts [k,v].inspect
      self[k] = v
    } unless default.nil? or default.keys.length == 0
    @dirty_keys = []
    @delete_keys = []
  end

  # Overrides key assignment with mongohash metadata
  
  def []=(key,value)
    @dirty_keys << key
    @delete_keys -= [key]
    super
  end

  # Overrides delete assignment with mongohash metadata
  
  def delete(key, mark = true)
    if mark == true
      @delete_keys << key
    end
    super(key)
  end

  # Removes the tied object from the mongo collection
  
  def destroy()
    unless @new_record == true
      retval = @collection.remove({'_id' => self._id}, :safe => true)
      @new_record = true
      self._id = nil
      ## maybe some other things
    end
  end

  # Persists the tied object to the mongo collection
  # if a new record, assigns self._id after success
  # if no keys have been modified, returns immediately
  # attempts to be smart about updating individual keys instead of overwriting entire record
  
  def save()
    @dirty_keys.uniq!
    @delete_keys.uniq!
    return nil if @dirty_keys.length == 0 and @delete_keys.length == 0

    if @new_record == true
      self['created_at'] = Time.now.to_i
      id = @collection.insert(self, :safe => true)
      self._id = id
      self.delete(:_id, false)
      @new_record = false
    else
      self['updated_at'] = Time.now.to_i

      ## @todo: what if the object with that key doesn't exist in the db when it's saved?

      if @subkey == ""
        if (@dirty_keys.length + @delete_keys.length) < self.keys.length / 2
          update_hash = {}
          @dirty_keys.map{|key| update_hash[key] = self[key]}
          delete_hash = {}
          @delete_keys.map{|key| delete_hash[key] = 1}
          @collection.update({'_id' => self._id}, {'$unset' => delete_hash, '$set' => update_hash }, :safe => true)           
          
          retval = true
        else
          retval = @collection.update({'_id' => self._id}, self, :safe => true)
        end
      else
        retval = @collection.update({'_id' => self._id}, {'$set' => {@subkey => self[@subkey]} }, :safe => true)
      end
    end
    @delete_keys = []
    @dirty_keys = []
    retval
  end
end

