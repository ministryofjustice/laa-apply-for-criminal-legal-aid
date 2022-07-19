Rails.application.routes.draw do

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  root 'home#index'
end
