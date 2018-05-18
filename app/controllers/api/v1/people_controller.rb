class Api::V1::PeopleController < ApplicationController
  
  def create
    person = PersonService.create(params, current_user)
    render plain: person.to_json    
  end

  def search_by_name_and_gender
    search_results = PersonService.search_by_name_and_gender(params)
    render plain: search_results.to_json  
  end

  def search_by_npid
    search_results = PersonService.search_by_npid(params)
    render plain: search_results.to_json
  end
  
  def search_by_doc_id
    search_results = PersonService.search_by_doc_id(params)
    render plain: search_results.to_json
  end
  
  def search_by_attributes
    search_results = PersonService.search_by_attributes(params)
    render plain: search_results.to_json
  end
  
  def update_person
    person = PersonService.update_person(params)
    render plain: person.to_json
  end
  
  def potential_duplicates
    potential_duplicates = PersonService.potential_duplicates(params)
    render plain: potential_duplicates.to_json
  end
  
  def merge_people
    merge_results = MergeService.merge(params[:primary_person_doc_id], params[:secondary_person_doc_id])
    render plain: merge_results.to_json
  end
  
end
