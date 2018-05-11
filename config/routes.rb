Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	
  namespace :api do
		namespace :v1 do
			resources :user
      resources :people
      resources :location
      resources :npid
		end
	end


  post 'v1/register', to: 'api/v1/user#register'
  post 'v1/login', to: 'api/v1/user#login'
  
  #people controller routes
  post 'v1/add_person', to: 'api/v1/people#create'

  #npid controller routes
  post 'v1/assign_npids', to: 'api/v1/npid#assign_npids'

  #location controller routes
  post 'v1/find_location', to: 'api/v1/location#find'




end
