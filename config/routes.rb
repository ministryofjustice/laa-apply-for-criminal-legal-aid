Rails.application.routes.draw do

  get '/health', to: 'healthcheck#show', as: :healthcheck

  root 'home#index'
end
