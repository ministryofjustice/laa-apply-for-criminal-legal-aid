module Decisions
  # rubocop:disable Metrics/ClassLength
  # TODO: Break to new `initial_details` tree
  class ClientDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :details
        after_client_details
      when :is_means_tested
        after_is_means_tested
      when :case_type
        after_case_type
      when :appeal_details
        after_appeal_details
      when :appeal_financial_circumstances
        after_financial_circumstances
      when :appeal_reference_number
        date_stamp_if_needed
      when :date_stamp
        after_date_stamp
      when :residence_type
        after_residence_type
      when :contact_details
        after_contact_details
      when :nino
        after_nino
      when :has_partner
        after_has_partner
      when :relationship_status
        after_relationship_status
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_client_details
      if form_object.crime_application.cifc?
        edit(:case_type)
      else
        edit(:is_means_tested)
      end
    end

    def after_is_means_tested
      if DateStamper.new(form_object.crime_application).call
        edit(:date_stamp)
      elsif form_object.crime_application.not_means_tested?
        edit(:residence_type)
      else
        edit(:case_type)
      end
    end

    def after_case_type
      return edit(:appeal_details) if form_object.case_type.appeal?

      date_stamp_if_needed
    end

    def after_appeal_details
      return date_stamp_if_needed if form_object.crime_application.cifc?

      if form_object.appeal_original_app_submitted.yes?
        edit(:appeal_financial_circumstances)
      else
        date_stamp_if_needed
      end
    end

    def after_financial_circumstances
      if form_object.appeal_financial_circumstances_changed.yes?
        date_stamp_if_needed
      else
        edit(:appeal_reference_number)
      end
    end

    def date_stamp_if_needed
      if DateStamper.new(form_object.crime_application, case_type: form_object.case.case_type).call
        edit(:date_stamp)
      else
        after_date_stamp
      end
    end

    def after_date_stamp
      if current_crime_application.appeal_no_changes?
        edit('/steps/case/urn')
      else
        edit(:residence_type)
      end
    end

    def after_residence_type
      if form_object.residence_type.none?
        edit(:contact_details)
      else
        start_address_journey(HomeAddress)
      end
    end

    def after_contact_details
      if form_object.correspondence_address_type.other_address?
        start_address_journey(CorrespondenceAddress)
      elsif current_crime_application.age_passported? || current_crime_application.appeal_no_changes?
        edit('/steps/case/urn')
      else
        edit('steps/shared/nino', subject: 'client')
      end
    end

    def start_address_journey(address_class)
      address = address_class.find_by(person: applicant)
      # check whether they previously entered an address manually
      if address && address.lookup_id.nil?
        edit('/steps/address/details', address_id: address)
      else
        address = address_class.find_or_create_by(person: applicant)
        edit('/steps/address/lookup', address_id: address)
      end
    end

    def after_nino
      if current_crime_application.not_means_tested?
        edit('/steps/case/urn')
      else
        edit('/steps/client/has_partner')
      end
    end

    def after_has_partner
      if form_object.has_partner.yes?
        edit('/steps/partner/relationship')
      else
        edit(:relationship_status)
      end
    end

    def after_relationship_status
      return edit('/steps/case/urn') if current_crime_application.applicant.arc.present?

      edit('/steps/dwp/benefit_type')
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
  # rubocop:enable Metrics/ClassLength
end
