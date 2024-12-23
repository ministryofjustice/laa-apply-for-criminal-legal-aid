module Decisions
  class IncomeDecisionTree < BaseDecisionTree # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize, Lint/DuplicateBranch, Metrics/PerceivedComplexity
    #
    include TypeOfMeansAssessment

    def destination # rubocop:disable Metrics/PerceivedComplexity
      case step_name
      when :employment_status
        after_employment_status
      when :armed_forces
        after_armed_forces
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
      when :partner_employment_income
        edit('/steps/income/income_payments_partner')
      when :client_self_assessment_tax_bill
        edit(:other_work_benefits)
      when :partner_self_assessment_tax_bill
        edit(:other_work_benefits)
      when :client_other_work_benefits
        edit('/steps/income/income_payments')
      when :partner_other_work_benefits
        edit('/steps/income/income_payments_partner')
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
        after_dependants_finished
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

    def client_employment
      @client_employment ||= if incomplete_client_employments.empty?
                               current_crime_application.client_employments.create!
                             else
                               incomplete_client_employments.first
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
      if form_object.add_client_employment.no?
        unless crime_application.income.employment_status.include?('self_employed')
          return edit('/steps/income/client/self_assessment_tax_bill')
        end

        start_self_employed_for(crime_application.applicant)
      else
        employment = current_crime_application.client_employments.create!

        redirect_to_employer_details(employment)
      end
    end

    def after_partner_employments_summary
      if form_object.add_partner_employment.no?
        unless crime_application.income.partner_employment_status.include?('self_employed')
          return edit('/steps/income/partner/self_assessment_tax_bill')
        end

        start_self_employed_for(crime_application.partner)
      else
        employment = current_crime_application.partner_employments.create!

        redirect_to_partner_employer_details(employment)
      end
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
        start_client_employment_journey
      end
    end

    def after_partner_employment_status
      if not_working?(form_object.partner_employment_status)
        edit(:income_payments_partner)
      else
        start_partner_employment_journey
      end
    end

    def after_armed_forces
      return partner_employment_start if form_object.form_subject == SubjectType::PARTNER

      edit(:income_before_tax)
    end

    def after_partner_income_benefits
      determine_showing_no_income_page
    end

    def start_client_employment_journey
      case form_object.employment_status
      when [EmploymentStatus::EMPLOYED.to_s]
        start_employed_for('client')
      when [EmploymentStatus::SELF_EMPLOYED.to_s]
        start_self_employed_for(crime_application.applicant)
      when [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        employment_start
      end
    end

    def start_partner_employment_journey
      case form_object.partner_employment_status
      when [EmploymentStatus::EMPLOYED.to_s]
        start_employed_for('partner')
      when [EmploymentStatus::SELF_EMPLOYED.to_s]
        start_self_employed_for(crime_application.partner)
      when [EmploymentStatus::EMPLOYED.to_s, EmploymentStatus::SELF_EMPLOYED.to_s]
        partner_employment_start
      end
    end

    def start_employed_for(subject)
      return edit(:armed_forces, subject:) if require_armed_forces?(subject)

      case subject
      when 'client'
        edit(:income_before_tax)
      when 'partner'
        partner_employment_start
      end
    end

    def start_self_employed_for(person)
      if person.businesses.any?
        edit('/steps/income/businesses_summary', subject: person)
      else
        edit('/steps/income/business_type', subject: person)
      end
    end

    def redirect_to_employer_details(employment)
      edit('/steps/income/client/employer_details', employment_id: employment)
    end

    def redirect_to_partner_employer_details(employment)
      edit('/steps/income/partner/employer_details', employment_id: employment)
    end

    def after_income_before_tax
      return after_extent_of_means_determined if extent_of_means_assessment_determined?

      edit(:frozen_income_savings_assets)
    end

    def after_frozen_income_savings_assets
      return after_extent_of_means_determined if extent_of_means_assessment_determined?

      edit(:client_owns_property)
    end

    def after_client_owns_property
      return after_extent_of_means_determined if extent_of_means_assessment_determined?

      edit(:has_savings)
    end

    def after_has_savings
      after_extent_of_means_determined
    end

    def after_extent_of_means_determined
      return edit(:income_payments) unless FeatureFlags.employment_journey.enabled? && employed?

      employment_start
    end

    def employment_start
      if requires_full_means_assessment?
        if income.client_employments.empty? || incomplete_client_employments.present?
          redirect_to_employer_details(client_employment)
        else
          edit('/steps/income/client/employments_summary')
        end
      else
        edit('/steps/income/client/employment_income')
      end
    end

    def partner_employment_start
      if requires_full_means_assessment?
        if income.partner_employments.empty? || incomplete_partner_employments.present?
          redirect_to_partner_employer_details(partner_employment)
        else
          edit('/steps/income/partner/employments_summary')
        end
      else
        edit('/steps/income/partner/employment_income')
      end
    end

    def after_income_benefits
      if requires_full_means_assessment?
        edit(:client_has_dependants)
      elsif include_partner_in_means_assessment?
        edit(:partner_employment_status)
      else
        determine_showing_no_income_page
      end
    end

    def after_client_has_dependants
      if form_object.client_has_dependants.yes?
        edit_dependants(add_blank: crime_application.dependants.none?)
      elsif include_partner_in_means_assessment?
        edit(:partner_employment_status)
      else
        determine_showing_no_income_page
      end
    end

    def edit_dependants(add_blank: false)
      dependants = crime_application.dependants
      dependants.create! if add_blank || dependants.empty?

      edit(:dependants)
    end

    def after_dependants_finished
      return edit(:partner_employment_status) if include_partner_in_means_assessment?

      determine_showing_no_income_page
    end

    def determine_showing_no_income_page
      if insufficient_income_declared?
        edit(:manage_without_income)
      else
        edit(:answers)
      end
    end

    def incomplete_client_employments
      income.client_employments.reject(&:complete?)
    end

    def incomplete_partner_employments
      income.partner_employments.reject(&:complete?)
    end

    def employed?
      crime_application.income.employment_status&.include?(EmploymentStatus::EMPLOYED.to_s) &&
        FeatureFlags.employment_journey.enabled?
    end

    def not_working?(employment_status)
      employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
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

    def require_armed_forces?(subject)
      income = crime_application.income

      return false if income.nil?

      income.send(:"require_#{subject}_in_armed_forces?")
    end
  end
end
