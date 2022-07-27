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

  resource :errors, only: [] do
    get :application_not_found
    get :invalid_session
    get :unhandled
    get :not_found
  end

  # Just for demo purposes, to be removed
  get 'home/selected_yes'
  get 'home/selected_no'

  get 'home/nino_yes'
  get 'home/nino_no'

  namespace :steps do
    namespace :client do
      edit_step :has_partner
      edit_step :details
      edit_step :has_nino
    end
  end

  # catch-all route
  # :nocov:
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
  # :nocov:
end
