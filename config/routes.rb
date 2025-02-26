def edit_step(name, opts = {}, &block)
  resource name.to_s.dasherize,
           only: opts.fetch(:only, [:edit, :update]),
           controller: opts.fetch(:alias, name),
           as: opts.fetch(:alias, name),
           path_names: { edit: '' } do
    yield if block
  end
  # temp underscored routes
  # if name.to_s.include?('_') && !block_given?
  #   get name, to: "#{opts.fetch(:alias, name)}#edit"
  #   patch name, to: "#{opts.fetch(:alias, name)}#update"
  #   put name, to: "#{opts.fetch(:alias, name)}#update"
  # end
end

def crud_step(name, opts = {})
  edit_step name, only: [] do
    resources only: [:edit, :update, :destroy],
              except: opts.fetch(:except, []),
              controller: opts.fetch(:alias, name), param: opts.fetch(:param),
              path_names: { edit: '' } do
      get :confirm_destroy, path: 'confirm-destroy', on: :member if parent_resource.actions.include?(:destroy)
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
    get :application_not_found, path: 'application-not-found'
    get :invalid_session, path: 'invalid-session'
    get :invalid_token, path: 'invalid-token'
    get :unhandled
    get :unauthenticated
    get :reauthenticate
    get :account_locked, path: 'account-locked'
    get :not_enrolled, path: 'not-enrolled'
    get :not_found, path: 'not-found'
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

  namespace :developer_tools, constraints: ->(_) { FeatureFlags.developer_tools.enabled? } do
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

  resources :crime_applications, except: [:show, :update], path: 'applications' do
    get :confirm_destroy, path: 'confirm-destroy', on: :member
    get :start, on: :collection

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

  scope 'applications' do
    resources :submitted_applications, path: 'submitted', only: [:index]
    resources :returned_applications, path: 'returned', only: [:index]
    resources :decided_applications, path: 'decided', only: [:index]
  end

  namespace :steps do
    namespace :provider do
      edit_step :confirm_office
      edit_step :select_office
    end
  end

  scope 'applications/:id' do
    namespace :steps do
      namespace :circumstances do
        edit_step :pre_cifc_reference_number
        edit_step :pre_cifc_reason
      end

      scope module: :shared do
        scope '/:subject/' do
          edit_step :nino
        end
      end

      namespace :client do
        edit_step :is_application_means_tested, alias: :is_means_tested
        edit_step :does_client_have_partner, alias: :has_partner
        edit_step :details
        edit_step :case_type
        edit_step :appeal_details
        edit_step :financial_circumstances_changed, alias: :appeal_financial_circumstances
        edit_step :appeal_reference_number
        edit_step :date_stamp
        edit_step :contact_details
        edit_step :residence_type
        edit_step :relationship_status
      end

      namespace :partner do
        edit_step :client_relationship_to_partner, alias: :relationship
        edit_step :partner_details, alias: :details
        edit_step :partner_involved_in_case, alias: :involvement
        edit_step :partner_conflict_of_interest, alias: :conflict
        edit_step :do_client_and_partner_live_same_address, alias: :same_address
        edit_step :enter_partner_address, alias: :address
      end

      namespace :dwp do
        edit_step :benefit_type
        edit_step :partner_benefit_type
        edit_step :benefit_check_result
        edit_step :cannot_check_benefit_status
        edit_step :has_benefit_evidence
        edit_step :cannot_check_dwp_status
        edit_step :confirm_result
        edit_step :confirm_details
      end

      namespace :address do
        crud_step :lookup,  param: :address_id, except: [:destroy]
        crud_step :results, param: :address_id, except: [:destroy]
        crud_step :details, param: :address_id, except: [:destroy]
      end

      namespace :case do
        edit_step :has_the_case_concluded, alias: :has_case_concluded
        edit_step :claim_pre_order_work, alias: :is_preorder_work_claimed
        edit_step :has_court_remanded_client_in_custody, alias: :is_client_remanded
        edit_step :urn
        crud_step :charges, param: :charge_id
        edit_step :charges_summary
        edit_step :has_codefendants
        edit_step :codefendants
        scope '/:subject/' do
          edit_step :other_charge_in_progress
          edit_step :other_charge
        end
        edit_step :hearing_details
        edit_step :first_court_hearing
        edit_step :ioj_passport
        edit_step :ioj
      end

      namespace :income do
        edit_step :what_is_clients_employment_status, alias: :employment_status
        edit_step :what_is_the_partners_employment_status, alias: :partner_employment_status
        namespace :client do
          crud_step :employments, param: :employment_id
          crud_step :employer_details, alias: :employer_details, param: :employment_id
          crud_step :employment_details, alias: :employment_details, param: :employment_id
          edit_step :employment_income
          edit_step :self_assessment_client, alias: :self_assessment_tax_bill
          crud_step :deductions_from_pay, alias: :deductions, param: :employment_id
          edit_step :add_employments, alias: :employments_summary
          edit_step :other_work_benefits_client, alias: :other_work_benefits
        end

        scope '/:subject/' do
          edit_step :business_type
          edit_step :businesses_summary
          crud_step :businesses, param: :business_id
          crud_step :nature_of_business, alias: :business_nature, param: :business_id, except: [:destroy]
          crud_step :date_business_began_trading, alias: :business_start_date, param: :business_id, except: [:destroy]
          crud_step :in_business_with_anyone_else, alias: :business_additional_owners, param: :business_id,
except: [:destroy]
          crud_step :employees, alias: :business_employees, param: :business_id, except: [:destroy]
          crud_step :financials_of_business, alias: :business_financials, param: :business_id, except: [:destroy]
          crud_step :salary_or_remuneration_as_director_or_shareholder, alias: :business_salary_or_remuneration,
param: :business_id, except: [:destroy]
          crud_step :total_income_from_share_sales, alias: :business_total_income_share_sales, param: :business_id,
except: [:destroy]
          crud_step :percentage_share_of_profits, alias: :business_percentage_profit_share, param: :business_id,
except: [:destroy]
        end

        scope '/:subject/' do
          edit_step :armed_forces
        end

        namespace :partner do
          crud_step :employments, param: :employment_id
          crud_step :employer_details, alias: :employer_details, param: :employment_id
          crud_step :employment_details, alias: :employment_details, param: :employment_id
          edit_step :employment_income
          edit_step :self_assessment_partner, alias: :self_assessment_tax_bill
          crud_step :deductions_from_pay, alias: :deductions, param: :employment_id
          edit_step :add_employments, alias: :employments_summary
          edit_step :other_work_benefits_partner, alias: :other_work_benefits
        end

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
        edit_step :which_payments_partner, alias: :income_payments_partner
        edit_step :which_benefits_partner, alias: :income_benefits_partner
        edit_step :what_is_the_partners_employment_status, alias: :partner_employment_status
      end

      namespace :outgoings do
        edit_step :housing_payments_where_lives, alias: :housing_payment_type
        edit_step :pay_council_tax, alias: :council_tax
        edit_step :client_paid_income_tax_rate, alias: :income_tax_rate
        edit_step :partner_paid_income_tax_rate, alias: :partner_income_tax_rate
        edit_step :are_outgoings_more_than_income, alias: :outgoings_more_than_income
        edit_step :which_payments, alias: :outgoings_payments
        edit_step :mortgage_payments, alias: :mortgage
        edit_step :rent_payments, alias: :rent
        edit_step :board_and_lodging_payments, alias: :board_and_lodging
        edit_step :check_your_answers_outgoings, alias: :answers
      end

      namespace :capital do
        edit_step :which_assets_owned, alias: :property_type
        edit_step :usual_property_details if FeatureFlags.property_ownership_validation.enabled?
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
        edit_step :partner_any_premium_bonds, alias: :partner_premium_bonds
        edit_step :partner_benefit_from_trust_fund, alias: :partner_trust_fund
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

  # temp underscored routes
  resource :application_searches, path: 'application-searches', only: [:new] do
    post :search, on: :collection
  end

  # catch-all route
  # :nocov:
  match '*path', to: 'errors#not_found', via: :all, constraints:
    ->(_request) { !Rails.application.config.consider_all_requests_local }
  # :nocov:
end
