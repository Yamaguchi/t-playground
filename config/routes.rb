Rails.application.routes.draw do
  resources :commands, only: [:index, :show] do
    member do
      resources :command_histories, only: [:create]
    end
  end

  root 'commands#index'
end
