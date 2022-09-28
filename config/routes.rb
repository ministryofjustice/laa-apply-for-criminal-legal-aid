def edit_step(name, opts = {}, &block)
  resource name,
           only: opts.fetch(:only, [:edit, :update]),
           controller: name,
           path_names: { edit: '' } do; block.call if block_given?; end
end

def crud_step(name, opts = {})
  edit_step name, only: [] do
    resources only: [:edit, :update, :destroy],
              except: opts.fetch(:except, []),
              controller: name, param: opts.fetch(:param),
              path_names: { edit: '' } do
      get :confirm_destroy, on: :member if parent_resource.actions.include?(:destroy)
    end
  end
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

  resource :session, only: [:destroy] do
    member do
      post :bypass_to_client_details
    end
  end

  resources :crime_applications, except: [:new, :update], path: 'applications' do
    get :confirm_destroy, on: :member
  end

  scope 'applications/:id' do
    namespace :steps do
      namespace :client do
        edit_step :has_partner
        edit_step :details
        edit_step :has_nino
        show_step :nino_exit
        show_step :partner_exit
        edit_step :contact_details
      end

      namespace :address do
        crud_step :lookup,  param: :address_id, except: [:destroy]
        crud_step :results, param: :address_id, except: [:destroy]
        crud_step :details, param: :address_id, except: [:destroy]
      end

      namespace :case do
        edit_step :urn
        edit_step :case_type
        show_step :date_stamp
        edit_step :has_codefendants
        edit_step :codefendants
        crud_step :charges, param: :charge_id
        edit_step :charges_summary
        edit_step :hearing_details
      end
    end
  end

  # catch-all route
  # :nocov:
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
  # :nocov:
end
