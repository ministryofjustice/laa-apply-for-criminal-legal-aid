def edit_step(name, &block)
  resource name,
           only: [:edit, :update],
           controller: name,
           path_names: { edit: '' } do; block.call if block_given?; end
end

def show_step(name)
  resource name, only: [:show], controller: name
end

Rails.application.routes.draw do

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  root 'home#index'

  # Just for demo purposes, to be removed
  get 'home/selected_yes'
  get 'home/selected_no'

  namespace :steps do
    namespace :client do
      edit_step :has_partner
    end
  end
end
