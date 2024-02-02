module Decisions
  # rubocop:disable Metrics/ClassLength
  # TODO: Break to new `initial_details` tree
  class PartnerDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :details
        after_partner_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private


    def after_partner_details
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
        show(:benefit_exit)
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

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
  # rubocop:enable Metrics/ClassLength
end
