Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	
  namespace :api do
		namespace :v1 do
			resources :user
      resources :people
      resources :location
      resources :npid
      resources :merge
		end
	end


  post 'v1/register', to: 'api/v1/user#register'
  post 'v1/login', to: 'api/v1/user#login'
  post 'v1/add_user', to: 'api/v1/user#add_user'
  
  #people controller routes
  post 'v1/add_person', to: 'api/v1/people#create'
  post 'v1/search_by_name_and_gender', to: 'api/v1/people#search_by_name_and_gender'
  post 'v1/search_by_npid', to: 'api/v1/people#search_by_npid'
  post 'v1/search_by_doc_id', to: 'api/v1/people#search_by_doc_id'
  post 'v1/search_by_attributes', to: 'api/v1/people#search_by_attributes'
  post 'v1/potential_duplicates', to: 'api/v1/people#potential_duplicates'
  post 'v1/merge_people', to: 'api/v1/people#merge_people'
  
  
  post 'v1/update_person/', to: 'api/v1/people#update_person'
  
  #npid controller routes
  post 'v1/assign_npids', to: 'api/v1/npid#assign_npids'

  #location controller routes
  post 'v1/find_location', to: 'api/v1/location#find'
  
  #footprint
  post 'v1/update_footprint/', to: 'api/v1/footprint#update_footprint'

  #merging
  post 'v1/merge_people', to: 'api/v1/merge#merge'




end
