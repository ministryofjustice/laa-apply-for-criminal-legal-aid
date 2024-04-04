module Decisions
  # rubocop:disable Metrics/ClassLength
  # TODO: Break to new `initial_details` tree
  class ClientDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :is_means_tested
        after_is_means_tested
      when :has_partner
        after_has_partner
      when :details
        after_client_details
      when :case_type
        after_case_type
      when :appeal_details
        date_stamp_if_needed
      when :date_stamp
        start_address_journey(HomeAddress)
      when :contact_details
        after_contact_details
      when :has_nino
        after_has_nino
      when :benefit_type
        after_benefit_type
      when :retry_benefit_check
        determine_dwp_result_page
      when :benefit_check_result
        after_dwp_check
      when :has_benefit_evidence
        after_has_benefit_evidence
      when :cannot_check_benefit_status
        after_cannot_check_benefit_status
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_is_means_tested
      if form_object.is_means_tested.yes?
        edit(:has_partner)
      else
        # Task list
        edit('/crime_applications')
      end
    end

    def after_has_partner
      if form_object.client_has_partner.yes?
        show(:partner_exit)
      else
        # Task list
        edit('/crime_applications')
      end
    end

    def after_client_details
      if DateStamper.new(form_object.crime_application).call
        edit(:date_stamp)
      elsif form_object.crime_application.not_means_tested?
        start_address_journey(HomeAddress)
      else
        edit(:case_type)
      end
    end

    def after_case_type
      return edit(:appeal_details) if form_object.case_type.appeal?

      date_stamp_if_needed
    end

    def date_stamp_if_needed
      if DateStamper.new(form_object.crime_application, case_type: form_object.case.case_type).call
        edit(:date_stamp)
      else
        start_address_journey(HomeAddress)
      end
    end

    def after_contact_details
      if form_object.correspondence_address_type.other_address?
        start_address_journey(CorrespondenceAddress)
      elsif current_crime_application.age_passported?
        edit('/steps/case/urn')
      else
        edit(:has_nino)
      end
    end

    def start_address_journey(address_class)
      address = address_class.find_or_create_by(person: applicant)

      edit('/steps/address/lookup', address_id: address)
    end

    def after_has_nino
      if current_crime_application.not_means_tested?
        edit('/steps/case/urn')
      else
        edit(:benefit_type)
      end
    end

    def after_benefit_type
      if form_object.benefit_type.none?
        if FeatureFlags.means_journey.enabled?
          edit('/steps/case/urn')
        else
          show(:benefit_exit)
        end
      elsif !applicant_has_nino
        edit(:cannot_check_benefit_status)
      else
        determine_dwp_result_page
      end
    end

    def determine_dwp_result_page
      return edit(:benefit_check_result) if current_crime_application.benefit_check_passported?

      DWP::UpdateBenefitCheckResultService.call(applicant)

      if applicant.passporting_benefit.nil?
        edit(:retry_benefit_check)
      elsif applicant.passporting_benefit
        edit(:benefit_check_result)
      else
        edit('steps/dwp/confirm_result')
      end
    end

    def after_dwp_check
      edit('/steps/case/urn')
    end

    def after_has_benefit_evidence
      if form_object.has_benefit_evidence.yes?
        edit('/steps/case/urn')
      else
        show(:evidence_exit)
      end
    end

    def after_cannot_check_benefit_status
      if form_object.will_enter_nino.yes?
        edit(:has_nino)
      else
        edit('/steps/case/urn')
      end
    end

    def applicant_has_nino
      return true unless FeatureFlags.means_journey.enabled?

      applicant.has_nino == 'yes'
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
  # rubocop:enable Metrics/ClassLength
end
