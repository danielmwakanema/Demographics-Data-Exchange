module CouchChanges
  def self.changes
    couchdb_yml = Rails.root.to_s + "/config/couchdb.yml"
    env = Rails.env
    couch_db_settings = YAML.load_file(couchdb_yml)[env]
    
    couch_host = couch_db_settings["host"]
    couch_prefix = couch_db_settings["prefix"]
    couch_suffix = couch_db_settings["suffix"]
    couch_db = couch_prefix.to_s + "_" + couch_suffix
    couch_port = couch_db_settings["port"]
    file_path = Rails.root.to_s + "/log/last_sequence.txt"
    last_sequence_number = (JSON.parse(File.open(file_path).read)["last_sequence"] rescue nil)

    if last_sequence_number.blank?
      couch_address = "http://#{couch_host}:#{couch_port}/#{couch_db}/_changes?include_docs=true"
    else
      couch_address = "http://#{couch_host}:#{couch_port}/#{couch_db}/_changes?since=#{last_sequence_number}&include_docs=true"
    end

    #raise couch_address.inspect
    received_params = RestClient.get(couch_address)
    results = JSON.parse(received_params)
    couch_data = {}
    seq = []
    couch_results = results["results"]
    last_sequence = results["last_seq"]
    puts "Starting from sequence#: #{last_sequence_number}"
    
    (couch_results || []).each do |result|
      type = result["doc"]["type"]
      id = result["doc"]["_id"]
      #raise result.inspect
      seq << result["seq"].to_i
      if (type == 'CouchdbUser')
        updateMysqlCouchdbUser(result["doc"])
      end

      if (type == 'CouchdbPerson')
        updateMysqlCouchdbPerson(result["doc"])
      end

      if (type == 'CouchdbLocationNpid')
        updateMysqlCouchdbLocationNpid(result["doc"])
      end
      #create_or_update_mysql_from_couch(couch_data, date)
    end

    last_sequence = seq.sort.last
    update_sequence_in_file(last_sequence) unless last_sequence.blank?
    return couch_data
  end

  def self.updateMysqlCouchdbUser(data)
    id = data["_id"]
    username = data["username"]
    email = data["email"]
    password_digest = data["password_digest"]
    couch_location_id = data["location_id"]
    voided = data["voided"]
    updated_at = data["updated_at"]
    created_at = data["created_at"]
    mysql_location_id = get_mysql_location_from_couchdb(couch_location_id)

    user = User.find_by_couchdb_user_id(id)
    if user.blank?
      User.create(couchdb_user_id: id, username: username, email: email, password_digest: password_digest,
        couchdb_location_id: couch_location_id, voided: voided, location_id: mysql_location_id)
    else
      user.update_attributes(username: username, email: email, couchdb_location_id: couch_location_id,
        voided: voided, location_id: mysql_location_id)
    end

  end

  def self.updateMysqlCouchdbPerson(data)
    id = data["_id"]
    given_name = data["given_name"]
    middle_name = data["middle_name"]
    family_name = data["family_name"]
    gender = data["gender"]
    birthdate = data["birthdate"]
    birthdate_estimated = data["birthdate_estimated"]
    died = data["died"]
    deathdate = data["deathdate"]
    deathdate_estimated = data["deathdate_estimated"]
    voided = data["voided"]
    date_voided = data["date_voided"]
    npid = data["npid"]
    location_created_at = data["location_created_at"]
    creator = data["creator"]
    created_at = data["created_at"]
    updated_at = data["updated_at"]

    mysql_location_id = get_mysql_location_from_couchdb(location_created_at)

    person = Person.find_by_couchdb_person_id(id)
    if person.blank?
      Person.create(couchdb_person_id: id, given_name: given_name, middle_name: middle_name, family_name: family_name,
        gender: gender, birthdate: birthdate, birthdate_estimated: birthdate_estimated,
        died: died, deathdate: deathdate, deathdate_estimated: deathdate_estimated, voided: voided,
        date_voided: date_voided, npid: npid, location_created_at: mysql_location_id,
        creator: creator, created_at: created_at, updated_at: updated_at
      )
    else
      person.update_attributes(given_name: given_name, middle_name: middle_name, family_name: family_name,
        gender: gender, birthdate: birthdate, birthdate_estimated: birthdate_estimated,
        died: died, deathdate: deathdate, deathdate_estimated: deathdate_estimated, voided: voided,
        date_voided: date_voided, npid: npid, location_created_at: mysql_location_id,
        creator: creator, created_at: created_at, updated_at: updated_at
      )
    end

  end

  def self.updateMysqlCouchdbLocationNpid(data)
    id = data["_id"]
    npid = data["npid"]
    location_id = data["location_id"]
    couchdb_location_id = data["couchdb_location_id"]
    mysql_location_id = get_mysql_location_from_couchdb(couchdb_location_id)
    

    location_npid = LocationNpid.find_by_couchdb_location_id(id)
    if location_npid.blank?
      LocationNpid.create(npid: npid, couchdb_location_id: id,
        location_id: mysql_location_id
      )
    else
      location_npid.update_attributes(npid: npid, couchdb_location_id: id,
        location_id: mysql_location_id
    end
  end
  
  def self.get_mysql_location_from_couchdb(couch_location_id)
    return 1
  end

  def create_or_update_mysql_from_couch(couch_data, date)

  end

  def self.update_sequence_in_file(last_sequence_number)
    data = {"last_sequence" => last_sequence_number}.to_json
    file_path = Rails.root.to_s + "/log/last_sequence.txt"
    File.open(file_path, "w") do |f|
      f.write(data)
    end
  end

  def self.allocate_ids_to_facility(location)
    npids = Npid.limit(10).where(assigned: false)
    npids.each do |npid_row|
      CouchdbLocationNpid.create(npid: npid_row.npid,
        location_id: location.couchdb_location_id)

      npid = Npid.find_by_npid(npid_row.npid)
      npid.assigned = true
      npid.save
    end
  end

end

