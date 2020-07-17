Rails.application.routes.draw do
  resources :commands, only: [:index, :edit, :update]
  root 'commands#index'
end
