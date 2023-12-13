module Decisions
  class IncomeDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :employment_status
        after_employment_status
      when :lost_job_in_custody
        # TODO: link to next step when we have it
        edit(:income_before_tax)
      when :income_before_tax
        after_income_before_tax
      when :frozen_income_savings_assets
        after_frozen_income_savings_assets
      when :client_owns_property
        after_client_owns_property
      when :has_savings
        edit(:income_payments)
      when :income_payments
        # TODO: link to next step when we have it
        edit(:client_has_dependants)
      when :client_has_dependants
        after_client_has_dependants
      when :add_dependant
        edit_dependants(add_blank: true)
      when :delete_dependant
        edit_dependants
      when :dependants_finished
        edit('/home', action: :index)
      when :manage_without_income
        # TODO: link to next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_employment_status
      if not_working?
        if ended_employment_within_three_months?
          edit(:lost_job_in_custody)
        else
          edit(:income_before_tax)
        end
      else
        # TODO: Update exit page content to include unemployed
        show(:employed_exit)
      end
    end

    def after_income_before_tax
      if income_below_threshold?
        edit(:frozen_income_savings_assets)
      else
        # TODO: once we have the next step
        edit(:client_has_dependants)
      end
    end

    def after_frozen_income_savings_assets
      if no_frozen_assets?
        edit(:client_owns_property)
      else
        # TODO: once we have the next step
        edit(:client_has_dependants)
      end
    end

    def after_client_owns_property
      if no_property?
        edit(:has_savings)
      else
        # TODO: once we have the next step
        edit(:client_has_dependants)
      end
    end

    def after_client_has_dependants
      if form_object.client_has_dependants.yes?
        edit_dependants(add_blank: true)
      else
        edit(:manage_without_income)
      end
    end

    def edit_dependants(add_blank: false)
      dependants = form_object.crime_application.dependants
      dependants.create! if add_blank || dependants.empty?

      edit(:dependants)
    end

    def not_working?
      form_object.employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
    end

    def ended_employment_within_three_months?
      form_object.ended_employment_within_three_months&.yes?
    end

    def income_below_threshold?
      form_object.income_above_threshold.no?
    end

    def no_frozen_assets?
      form_object.has_frozen_income_or_assets.no?
    end

    def no_property?
      form_object.client_owns_property.no?
    end
  end
end
