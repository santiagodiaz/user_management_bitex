Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users do

  end

  get '/test_connection', to: "users#test_connection"

  get '/users/:user_id/check_issue_status/:issue_id', to: "users#check_issue_status"

  root "users#index"
end
