module PersonService
  def self.create(params)
    given_name = params[:given_name]
    family_name = params[:family_name]
    middle_name = params[:middle_name]
    gender = params[:gender]
    birthdate = params[:birthdate]
    birthdate_estimated = params[:birthdate_estimated]

    occupation = params[:attributes][:occupation]
    cellphone_number = params[:attributes][:cellphone_number]
    current_district = params[:attributes][:current_district]
    current_ta = params[:attributes][:current_traditional_authority]
    current_village = params[:attributes][:current_village]

    home_district = params[:attributes][:home_district]
    home_ta = params[:attributes][:home_traditional_authority]
    home_village = params[:attributes][:home_village]

    art_number = params[:identifiers][:art_number]
    htn_number = params[:identifiers][:htn_number]

    ActiveRecord::Base.transaction do
      couchdb_person = CouchdbPerson.create(given_name: given_name, family_name: family_name,
        middle_name: middle_name, gender: gender, birthdate: birthdate,
        birthdate_estimated: birthdate_estimated)

      person = Person.create(given_name: given_name, family_name: family_name,
        middle_name: middle_name, gender: gender, birthdate: birthdate,
        birthdate_estimated: birthdate_estimated, couchdb_person_id: couchdb_person.id)

    end
    
    return couchdb_person
  end
end