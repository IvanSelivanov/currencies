Rails.application.routes.draw do

  root to: "pairs#index"
  resources :pairs do
    resource :ticker, only: [:update]
  end
  get 'update_pairs', to: "pairs#update_all", as: 'update_all_pairs'
  get "/pairs/:id/history", to: "pairs#history", as: 'pair_history'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
