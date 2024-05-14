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
              controller: opts.fetch(:alias, name), param: opts.fetch(:param),
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
      get 'logout', to: 'sessions#destroy', as: :logout
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
                param: :document_id, as: 'crime_application_documents' do
        get :download, on: :member
      end
    end

    scope :completed, as: :completed, controller: :completed_applications do
      get :index, on: :collection
      get :show, on: :member
      put :recreate, on: :member
      post(:create_pse, on: :member)
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
        if FeatureFlags.non_means_tested.enabled?
          edit_step :is_application_means_tested, alias: :is_means_tested
        end
        edit_step :has_partner
        show_step :partner_exit
        edit_step :details
        edit_step :case_type
        edit_step :appeal_details
        edit_step :financial_circumstances_changed, alias: :appeal_financial_circumstances
        edit_step :appeal_reference_number
        edit_step :date_stamp
        edit_step :has_nino
        show_step :nino_exit
        edit_step :contact_details
        edit_step :residence_type
      end

      namespace :dwp do
        edit_step :benefit_type
        show_step :benefit_exit
        edit_step :benefit_check_result
        edit_step :cannot_check_benefit_status
        edit_step :has_benefit_evidence
        show_step :evidence_exit
        edit_step :cannot_check_dwp_status
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
        if FeatureFlags.means_journey.enabled?
          edit_step :has_the_case_concluded, alias: :has_case_concluded
          edit_step :claim_pre_order_work,  alias: :is_preorder_work_claimed
          edit_step :has_court_remanded_client_in_custody,  alias: :is_client_remanded
        end
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
        namespace :client do
          crud_step :employer_details, alias: :employer_details, param: :employment_id
          edit_step :employment_income
        end
        show_step :employed_exit
        edit_step :did_client_lose_job_being_in_custody, alias: :lost_job_in_custody
        edit_step :current_income_before_tax, alias: :income_before_tax
        edit_step :income_savings_assets_under_restraint_freezing_order, alias: :frozen_income_savings_assets
        edit_step :own_home_land_property, alias: :client_owns_property
        edit_step :any_savings_investments, alias: :has_savings
        edit_step :does_client_have_dependants, alias: :client_has_dependants
        edit_step :dependants, alias: :dependants
        edit_step :how_manage_with_no_income, alias: :manage_without_income
        edit_step :which_payments_client, alias: :income_payments
        edit_step :which_benefits_client, alias: :income_benefits
        edit_step :check_your_answers_income, alias: :answers
      end

      namespace :outgoings, constraints: -> (_) { FeatureFlags.means_journey.enabled? } do
        edit_step :housing_payments_where_lives, alias: :housing_payment_type
        edit_step :pay_council_tax, alias: :council_tax
        edit_step :client_paid_income_tax_rate, alias: :income_tax_rate
        edit_step :are_outgoings_more_than_income, alias: :outgoings_more_than_income
        edit_step :which_payments, alias: :outgoings_payments
        edit_step :mortgage_payments, alias: :mortgage
        edit_step :rent_payments, alias: :rent
        edit_step :board_and_lodging_payments, alias: :board_and_lodging
        edit_step :check_your_answers_outgoings, alias: :answers
      end

      namespace :capital, constraints: -> (_) { FeatureFlags.means_journey.enabled? } do
        edit_step :which_assets_owned, alias: :property_type
        crud_step :residential_property, alias: :residential_property, param: :property_id
        crud_step :commercial_property, alias: :commercial_property, param: :property_id
        crud_step :land, alias: :land, param: :property_id
        crud_step :asset_address, alias: :property_address, param: :property_id, except: [:destroy]
        crud_step :asset_owners, alias: :property_owners, param: :property_id, except: [:destroy]
        edit_step :add_assets, alias: :properties_summary
        crud_step :properties, param: :property_id
        edit_step :which_other_assets_owned, alias: :other_property_type

        edit_step :which_savings, alias: :saving_type
        edit_step :which_other_savings, alias: :other_saving_type
        crud_step :savings, param: :saving_id
        edit_step :add_savings_accounts, alias: :savings_summary

        edit_step :any_national_savings_certificates, alias: :has_national_savings_certificates
        crud_step :national_savings_certificates, param: :national_savings_certificate_id
        edit_step :add_national_savings_certificates, alias: :national_savings_certificates_summary

        edit_step :which_investments, alias: :investment_type
        edit_step :which_other_investments, alias: :other_investment_type
        crud_step :investments, param: :investment_id
        edit_step :add_investments, alias: :investments_summary

        edit_step :client_any_premium_bonds, alias: :premium_bonds
        edit_step :client_benefit_from_trust_fund, alias: :trust_fund
        edit_step :income_savings_assets_under_restraint_freezing_order, alias: :frozen_income_savings_assets_capital

        edit_step :check_your_answers_capital, alias: :answers
      end

      namespace :evidence do
        edit_step :upload
      end

      namespace :submission do
        edit_step :more_information
        edit_step :review
        edit_step :declaration
        edit_step :failure
        show_step :confirmation
        edit_step :cannot_submit_without_nino
      end
    end
  end

  # catch-all route
  # :nocov:
  match '*path', to: 'errors#not_found', via: :all, constraints:
    lambda { |_request| !Rails.application.config.consider_all_requests_local }
  # :nocov:
end
