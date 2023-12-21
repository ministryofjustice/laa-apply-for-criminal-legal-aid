def edit_step(name, opts = {}, &block)
  resource name,
           only: opts.fetch(:only, [:edit, :update]),
           controller: opts.fetch(:alias, name),
           as: opts.fetch(:alias, name),
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

    member do
      resources :documents, only: [:create, :destroy],
                param: :document_id, as: 'crime_application_documents',
                constraints: -> (_) { FeatureFlags.evidence_upload.enabled? } do
        get :download, on: :member
      end
    end

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
        show_step :partner_exit
        edit_step :details
        edit_step :has_nino
        show_step :nino_exit
        edit_step :benefit_type
        show_step :benefit_exit
        edit_step :benefit_check_result
        edit_step :retry_benefit_check
        if FeatureFlags.evidence_upload.enabled?
          edit_step :has_benefit_evidence
          show_step :evidence_exit
        end
        edit_step :contact_details
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
        edit_step :first_court_hearing
        edit_step :ioj_passport
        edit_step :ioj
      end

      namespace :income, constraints: -> (_) { FeatureFlags.means_journey.enabled? } do
        edit_step :what_is_clients_employment_status, alias: :employment_status
        show_step :employed_exit
        edit_step :did_client_lose_job_being_in_custody, alias: :lost_job_in_custody
        edit_step :clients_income_before_tax, alias: :income_before_tax
        edit_step :income_savings_assets_under_restraint_freezing_order, alias: :frozen_income_savings_assets
        edit_step :does_client_own_home_land_property, alias: :client_owns_property
        edit_step :does_client_have_savings_investments, alias: :has_savings
        edit_step :does_client_have_dependants, alias: :client_has_dependants
        edit_step :dependants, alias: :dependants
        edit_step :how_does_client_manage_with_no_income, alias: :manage_without_income
      end

      namespace :outgoings, constraints: -> (_) { FeatureFlags.means_journey.enabled? } do
        edit_step :has_client_paid_income_tax_rate, alias: :income_tax_rate
        edit_step :are_clients_outgoings_more_than_income, alias: :outgoings_more_than_income
      end

      namespace :evidence, constraints: -> (_) { FeatureFlags.evidence_upload.enabled? } do
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
