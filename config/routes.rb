Rails.application.routes.draw do
  root 'choose_action#index'

  get '/choose_action', to: 'choose_action#index'
  get '/postcode_arrivals', to: 'postcode_arrivals#index'
  get '/stop_id_arrivals', to: 'stop_id_arrivals#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
