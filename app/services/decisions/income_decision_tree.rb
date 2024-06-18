module Decisions
  class IncomeDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Lint/DuplicateBranch, Metrics/PerceivedComplexity
    #
    include TypeOfMeansAssessment

    def destination # rubocop:disable Metrics/PerceivedComplexity
      case step_name
      when :employment_status
        after_employment_status
      when :client_employer_details
        after_client_employer_details
      when :partner_employer_details
        after_partner_employer_details
      when :client_employment_details
        after_client_employment_details
      when :partner_employment_details
        after_partner_employment_details
      when :client_deductions
        after_client_deductions
      when :partner_deductions
        after_partner_deductions
      when :client_employments_summary
        after_client_employments_summary
      when :partner_employments_summary
        after_partner_employments_summary
      when :lost_job_in_custody
        edit(:income_before_tax)
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
      when :client_self_assessment_tax_bill
        edit(:other_work_benefits)
      when :partner_self_assessment_tax_bill
        # TODO: Implement next step for partner income payments
        edit('/steps/income/income_payments')
      when :client_other_work_benefits
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
      when :partner_employment_status
        after_partner_employment_status
      when :income_payments_partner
        edit(:income_benefits_partner)
      when :income_benefits_partner
        after_partner_income_benefits
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
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Lint/DuplicateBranch, Metrics/PerceivedComplexity

    private

    def employment
      @employment ||= if incomplete_employments.empty?
                        current_crime_application.employments.create!
                      else
                        incomplete_employments.first
                      end
    end

    def partner_employment
      @partner_employment ||= if incomplete_partner_employments.empty?
                                current_crime_application.partner_employments.create!
                              else
                                incomplete_partner_employments.first
                              end
    end

    def after_client_employments_summary
      return edit(:self_assessment_tax_bill) if form_object.add_client_employment.no?

      employment = current_crime_application.employments.create!
      redirect_to_employer_details(employment)
    end

    def after_partner_employments_summary
      return edit(:self_assessment_tax_bill) if form_object.add_partner_employment.no?

      employment = current_crime_application.partner_employments.create!
      redirect_to_partner_employer_details(employment)
    end

    def previous_step_path
      # Second to last element in the array, will be nil for arrays of size 0 or 1
      current_crime_application&.navigation_stack&.slice(-2) || root_path
    end

    def after_employment_status
      if not_working?(form_object.employment_status)
        if ended_employment_within_three_months?
          edit(:lost_job_in_custody)
        else
          edit(:income_before_tax)
        end
      else
        return show(:employed_exit) unless FeatureFlags.employment_journey.enabled?

        start_employment_journey
      end
    end

    def after_partner_employment_status
      if not_working?(form_object.partner_employment_status)
        edit(:income_payments_partner)
      elsif self_employed?(form_object.partner_employment_status)
        if FeatureFlags.self_employed_journey.enabled?
          edit('/steps/income/business_type', subject: 'partner')
        else
          show(:self_employed_exit)
        end
      else
        return show(:employed_exit) unless FeatureFlags.employment_journey.enabled?

        start_partner_employment_journey
      end
    end

    def after_partner_income_benefits
      if crime_application.income&.all_income_over_zero?
        edit(:answers)
      else
        edit(:manage_without_income)
      end
    end

    # <- to make it easier to reimplement when we do self-employed
    def start_employment_journey
      case form_object.employment_status
      when [EmploymentStatus::EMPLOYED.to_s]
        edit(:income_before_tax)
      when [EmploymentStatus::SELF_EMPLOYED.to_s]
        if FeatureFlags.self_employed_journey.enabled?
          edit('/steps/income/business_type', subject: 'client')
        else
          show(:self_employed_exit)
        end
      when [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        redirect_to_employer_details(employment)
      end
    end

    def start_partner_employment_journey
      case form_object.partner_employment_status
      when [EmploymentStatus::EMPLOYED.to_s]
        # TODO: Redirect to partner's employment income
        # edit(:income_before_tax)
      when [EmploymentStatus::SELF_EMPLOYED.to_s]
        show(:self_employed_exit)
      when [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        redirect_to_partner_employer_details(partner_employment)
      end
    end

    def redirect_to_employer_details(employment)
      edit('/steps/income/client/employer_details', employment_id: employment)
    end

    def redirect_to_partner_employer_details(employment)
      edit('/steps/income/partner/employer_details', employment_id: employment)
    end

    def after_income_before_tax
      if income_below_threshold?
        edit(:frozen_income_savings_assets)
      elsif employed? && FeatureFlags.employment_journey.enabled?
        redirect_to_employer_details(employment)
      else
        edit(:income_payments)
      end
    end

    def after_frozen_income_savings_assets
      if has_frozen_assets?
        employed? ? redirect_to_employer_details(employment) : edit(:income_payments)
      elsif summary_only? || committal?
        employed? ? edit('/steps/income/client/employment_income') : edit(:income_payments)
      else
        edit(:client_owns_property)
      end
    end

    def after_has_savings
      return edit(:income_payments) unless FeatureFlags.employment_journey.enabled? && employed?

      if requires_full_means_assessment?
        redirect_to_employer_details(employment)
      else
        edit('/steps/income/client/employment_income')
      end
    end

    def after_client_owns_property
      if no_property?
        edit(:has_savings)
      elsif employed? && FeatureFlags.employment_journey.enabled?
        redirect_to_employer_details(employment)
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
        edit_dependants(add_blank: crime_application.dependants.none?)
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
      if FeatureFlags.partner_journey.enabled? && include_partner_in_means_assessment?
        edit(:partner_employment_status)
      elsif income_payments.empty? && income_benefits.empty?
        edit(:manage_without_income)
      else
        edit(:answers)
      end
    end

    def incomplete_employments
      crime_application.employments.reject(&:complete?)
    end

    def incomplete_partner_employments
      crime_application.partner_employments.reject(&:complete?)
    end

    def employed?
      crime_application.income.employment_status&.include?(EmploymentStatus::EMPLOYED.to_s) &&
        FeatureFlags.employment_journey.enabled?
    end

    def not_working?(employment_status)
      employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
    end

    def self_employed?(employment_status)
      employment_status.include?(EmploymentStatus::SELF_EMPLOYED.to_s)
    end

    def ended_employment_within_three_months?
      form_object.ended_employment_within_three_months&.yes?
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
      edit('steps/income/client/employment_details', employment_id: form_object.record.id)
    end

    def after_partner_employer_details
      edit('steps/income/partner/employment_details', employment_id: form_object.record.id)
    end

    def after_client_employment_details
      edit('/steps/income/client/deductions', employment_id: form_object.record.id)
    end

    def after_partner_employment_details
      edit('/steps/income/partner/deductions', employment_id: form_object.record.id)
    end

    def after_client_deductions
      edit('/steps/income/client/employments_summary')
    end

    def after_partner_deductions
      edit('/steps/income/partner/employments_summary')
    end
  end
end
