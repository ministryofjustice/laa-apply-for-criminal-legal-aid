module Decisions
  class IncomeDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    def destination
      case step_name
      when :employment_status
        after_employment_status
      when :lost_job_in_custody
        after_lost_job_in_custody
      when :income_before_tax
        after_income_before_tax
      when :frozen_income_savings_assets
        after_frozen_income_savings_assets
      when :client_owns_property
        after_client_owns_property
      when :has_savings
        edit(:income_payments)
      when :income_payments
        edit(:income_benefits)
      when :income_benefits
        after_income_benefits
      when :client_has_dependants
        after_client_has_dependants
      when :add_dependant
        edit_dependants(add_blank: true)
      when :delete_dependant
        edit_dependants
      when :dependants_finished
        determine_showing_no_income_page
      when :manage_without_income
        # TODO: link to next step when we have it
        edit('/steps/outgoings/housing_payment_type')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_employment_status
      if not_working?
        if ended_employment_within_three_months?
          edit(:lost_job_in_custody)
        elsif appeal_no_changes?
          edit('/steps/evidence/upload')
        else
          edit(:income_before_tax)
        end
      else
        # TODO: Update exit page content to include unemployed
        show(:employed_exit)
      end
    end

    def after_lost_job_in_custody
      if appeal_no_changes?
        edit('/steps/evidence/upload')
      else
        edit(:income_before_tax)
      end
    end

    def after_income_before_tax
      if income_below_threshold?
        edit(:frozen_income_savings_assets)
      else
        edit(:income_payments)
      end
    end

    def after_frozen_income_savings_assets
      if no_frozen_assets?
        edit(:client_owns_property)
      else
        edit(:income_payments)
      end
    end

    def after_client_owns_property
      if no_property?
        edit(:has_savings)
      else
        edit(:income_payments)
      end
    end

    def after_income_benefits
      if dependants_relevant?
        edit(:client_has_dependants)
      else
        determine_showing_no_income_page
      end
    end

    def after_client_has_dependants
      if form_object.client_has_dependants.yes?
        edit_dependants(add_blank: true)
      else
        determine_showing_no_income_page
      end
    end

    def edit_dependants(add_blank: false)
      dependants = crime_app.dependants
      dependants.create! if add_blank || dependants.empty?

      edit(:dependants)
    end

    def determine_showing_no_income_page
      if payments.empty?
        edit(:manage_without_income)
      else
        edit('/steps/outgoings/housing_payment_type')
      end
    end

    def not_working?
      form_object.employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
    end

    def ended_employment_within_three_months?
      form_object.ended_employment_within_three_months&.yes?
    end

    def appeal_no_changes?
      crime_app.case.case_type == CaseType::APPEAL_TO_CROWN_COURT.to_s
    end

    def summary_only?
      crime_app.case.case_type == CaseType::SUMMARY_ONLY.to_s
    end

    def income_below_threshold?
      crime_app.income.income_above_threshold == 'no'
    end

    def no_frozen_assets?
      crime_app.income.has_frozen_income_or_assets == 'no'
    end

    def no_property?
      crime_app.income.client_owns_property == 'no'
    end

    def no_savings?
      crime_app.income.has_savings == 'no'
    end

    def payments
      crime_app.income_payments + crime_app.income_benefits
    end

    def crime_app
      form_object.crime_application
    end

    def dependants_relevant?
      if income_below_threshold? && no_frozen_assets?
        !(summary_only? || (no_property? && no_savings?))
      else
        true
      end
    end
  end
end
