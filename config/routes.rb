Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  #MVP - Access to the dashboad
  get 'dashboard', to: 'pages#dashboard'

  # MVP - Create a garden and plots into the garden
  resources 'gardens', only: [:new, :create, :show, :index] do
    resources 'plots', only: [:new, :create]
  end

  # MVP- Update and destroy plots
  resources 'plots', only: [:update, :edit, :destroy, :show] do
    get '/waterings', to: "waterings#watering_plot"
    patch '/complete_waterings', to: 'waterings#complete_plot_watering'
    #MVP - create plants inside a plot
    resources 'plants', only: [:create]
  end
  #MVP - Watering see the all the watering, and update the amount
  get 'waterings', to: "waterings#watering_overview"
  #MVP - Mark the plants as watered
  patch 'waterings/:id/complete', to: 'waterings#mark_as_complete', as: :complete_watering


  # MVP - Destroy plants and update (location)
  resources 'plants', only: [:destroy, :update]
  post 'plants', to: "plants#copy", as: :copy_plant

  #MVP - Tasks index | IMPORTANT create update and destroy (the creation)
  resources 'tasks', only: [:index, :create, :edit, :update, :destroy]

  #MVP - Mark task as complete
  patch 'tasks/:id/complete', to: 'tasks#mark_as_complete'

  #IMPORTANT - mark a plot as watered

  #IMPORTANT - See current weather, forecast and alerts
  resources 'weather_stations', only: [:index, :show] do
    patch 'weather_alert/:id/dismissed', to: 'weather_alerts#mark_as_dismissed', as: :dismissed_alert
  end

  #NICE TO HAVE - Display all conversations and create a message
  resources 'conversations', only: [:index, :show] do
    resources 'messages', only:[:create]
  end

  #NICE TO HAVE - Display all users
  get 'users', to: 'users#index'

  #NICE TO HAVE - See one user and create a new conversation with it
  get 'users/:user_id', to: 'users#show' do
    resources 'conversations', only: [:new, :create]
  end

end
