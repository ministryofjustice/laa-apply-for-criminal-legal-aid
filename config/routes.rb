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
  mount DatastoreApi::HealthEngine::Engine => '/datastore'

  get :health, to: 'healthcheck#show'
  get :ping,   to: 'healthcheck#ping'

  root 'home#index'

  resource :errors, only: [] do
    get :application_not_found
    get :invalid_session
    get :invalid_token
    get :unhandled
    get :unauthenticated
    get :reauthenticate
    get :account_locked
    get :not_enrolled
    get :not_found
  end

  devise_for :providers,
             skip: [:all],
             controllers: {
               omniauth_callbacks: 'providers/omniauth_callbacks'
             }

  devise_scope :provider do
    get 'login', to: 'errors#unauthenticated', as: :new_provider_session

    namespace :providers do
      delete 'logout', to: 'sessions#destroy', as: :logout
    end
  end

  namespace :developer_tools, constraints: -> (_) { FeatureFlags.developer_tools.enabled? } do
    resources :crime_applications, only: [:update, :destroy], path: 'applications' do
      put :bypass_dwp, on: :member
      put :under18_bypass, on: :member
      put :mark_as_returned, on: :member
    end
  end

  namespace :about do
    get :privacy
    get :contact
    get :accessibility
  end

  # Handle the cookies consent
  resource :cookies, only: [:show, :update]

  resources :crime_applications, except: [:show, :new, :update], path: 'applications' do
    get :confirm_destroy, on: :member

    scope :completed, as: :completed, controller: :completed_applications do
      get :index, on: :collection
      get :show, on: :member
      put :recreate, on: :member
    end
  end

  namespace :steps do
    namespace :provider do
      edit_step :confirm_office
      edit_step :select_office
    end
  end

  scope 'applications/:id' do
    namespace :steps do
      namespace :client do
        edit_step :has_partner
        edit_step :details
        edit_step :has_nino
        edit_step :benefit_check_result
        show_step :nino_exit
        show_step :partner_exit
        edit_step :contact_details
        edit_step :retry_benefit_check
      end

      namespace :dwp do
        edit_step :confirm_result
        edit_step :confirm_details
        show_step :benefit_check_result_exit
      end

      namespace :address do
        crud_step :lookup,  param: :address_id, except: [:destroy]
        crud_step :results, param: :address_id, except: [:destroy]
        crud_step :details, param: :address_id, except: [:destroy]
      end

      namespace :case do
        edit_step :case_type
        edit_step :appeal_details
        edit_step :date_stamp
        edit_step :urn
        crud_step :charges, param: :charge_id
        edit_step :charges_summary
        edit_step :has_codefendants
        edit_step :codefendants
        edit_step :hearing_details
        edit_step :ioj_passport
        edit_step :ioj
      end

      namespace :evidence do
        edit_step :upload
      end

      namespace :submission do
        edit_step :review
        edit_step :declaration
        edit_step :failure
        show_step :confirmation
      end
    end
  end

  # catch-all route
  # :nocov:
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
  # :nocov:
end
