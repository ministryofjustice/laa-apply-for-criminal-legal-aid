module Decisions
  class IncomeDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    #
    include TypeOfMeansAssessment

    def destination
      case step_name
      when :employment_status
        after_employment_status
      when :client_employer_details
        after_client_employer_details
      when :lost_job_in_custody
        after_lost_job_in_custody
      when :income_before_tax
        after_income_before_tax
      when :frozen_income_savings_assets
        after_frozen_income_savings_assets
      when :client_owns_property
        after_client_owns_property
      when :has_savings
        after_has_savings
      when :client_employment_income
        edit('/steps/income/income_payments')
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
        edit(:answers)
      when :answers
        step_path = Rails.application.routes.url_helpers
        if previous_step_path.in? [
          step_path.edit_steps_income_employment_status_path(id: crime_application.id),
          step_path.edit_steps_income_lost_job_in_custody_path(id: crime_application.id)
        ]
          continuing_evidence_upload
        else
          determine_continuing_means_journey
        end
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def previous_step_path
      # Second to last element in the array, will be nil for arrays of size 0 or 1
      current_crime_application&.navigation_stack&.slice(-2) || root_path
    end

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
        return show(:employed_exit) unless FeatureFlags.employment_journey.enabled?

        start_employment_journey
      end
    end

    def start_employment_journey
      case form_object.employment_status
      when [EmploymentStatus::EMPLOYED.to_s]
        edit(:income_before_tax)
      when [EmploymentStatus::SELF_EMPLOYED.to_s]
        show(:employed_exit)
      when [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        employments = current_crime_application.employments
        current_crime_application.employments.create! if employments.empty?
        edit('steps/income/client/employer_details', employment_id: employments.first)
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
      if no_frozen_assets? && !summary_only?
        edit(:client_owns_property)
      else
        edit(:income_payments)
      end
    end

    def after_has_savings
      return edit(:income_payments) unless FeatureFlags.employment_journey.enabled?

      if employed?
        edit('steps/income/client/employment_income')
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
      if requires_full_means_assessment?
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
      dependants = crime_application.dependants
      dependants.create! if add_blank || dependants.empty?

      edit(:dependants)
    end

    def determine_showing_no_income_page
      if income_payments.empty? && income_benefits.empty?
        edit(:manage_without_income)
      else
        edit(:answers)
      end
    end

    def employed?
      crime_application.income.employment_status.include?(EmploymentStatus::EMPLOYED.to_s)
    end

    def not_working?
      form_object.employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
    end

    def ended_employment_within_three_months?
      form_object.ended_employment_within_three_months&.yes?
    end

    def appeal_no_changes?
      kase.case_type == CaseType::APPEAL_TO_CROWN_COURT.to_s &&
        kase.appeal_financial_circumstances_changed == 'no'
    end

    def crime_application
      form_object.crime_application
    end

    def determine_continuing_means_journey
      if requires_full_means_assessment?
        edit('/steps/outgoings/housing_payment_type')
      else
        edit('/steps/evidence/upload')
      end
    end

    def continuing_evidence_upload
      edit('/steps/evidence/upload')
    end

    def after_client_employer_details
      # TODO: Add employment details page to complete the journey
      show('/steps/income/employed_exit')
    end
  end
end
