module Decisions
  # rubocop:disable Metrics/ClassLength
  class DWPDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :benefit_type
        after_benefit_type
      when :partner_benefit_type
        after_partner_benefit_type
      when :benefit_check_result
        edit('/steps/case/urn')
      when :has_benefit_evidence
        after_has_benefit_evidence
      when :cannot_check_benefit_status
        after_cannot_check_benefit_status
      when :cannot_check_dwp_status
        after_cannot_check_dwp_status
      when :confirm_result
        after_confirm_result
      when :confirm_details
        after_confirm_details
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_confirm_result
      if form_object.confirm_dwp_result.yes?
        if FeatureFlags.means_journey.enabled?
          edit('steps/case/urn')
        else
          show(:benefit_check_result_exit)
        end
      else
        edit(:confirm_details)
      end
    end

    def after_confirm_details
      if form_object.confirm_details.yes?
        edit(:has_benefit_evidence)
      else
        edit('steps/client/details')
      end
    end

    def after_benefit_type
      return edit(:partner_benefit_type) if partner_benefit_type_required?

      benefit_check_routing(applicant)
    end

    def after_partner_benefit_type
      benefit_check_routing(partner)
    end

    def benefit_check_routing(person)
      if form_object.benefit_type.none?
        if FeatureFlags.means_journey.enabled?
          edit('/steps/case/urn')
        else
          show(:benefit_exit)
        end
      elsif !has_nino(person)
        edit(:cannot_check_benefit_status)
      else
        determine_dwp_result_page(person)
      end
    end

    def partner_benefit_type_required?
      # TODO: refactor to use has_partner in partner_details table instead of client_has_partner

      form_object.benefit_type.none? &&
        FeatureFlags.passported_partner_journey.enabled? &&
        current_crime_application.client_has_partner == 'yes'
    end

    def after_has_benefit_evidence
      if form_object.has_benefit_evidence.yes? || FeatureFlags.means_journey.enabled?
        edit('/steps/case/urn')
      else
        show(:evidence_exit)
      end
    end

    def after_cannot_check_benefit_status
      if form_object.will_enter_nino.yes?
        edit('steps/client/has_nino')
      else
        edit('/steps/case/urn')
      end
    end

    def determine_dwp_result_page(person)
      return edit(:benefit_check_result) if current_crime_application.benefit_check_passported?

      DWP::UpdateBenefitCheckResultService.call(person)

      if person.passporting_benefit.nil?
        edit(:cannot_check_dwp_status)
      elsif person.passporting_benefit
        edit(:benefit_check_result)
      else
        edit(:confirm_result)
      end
    end

    def after_cannot_check_dwp_status
      person = benefit_check_recipient

      determine_dwp_result_page(person)
    end

    def has_nino(person)
      return true unless FeatureFlags.means_journey.enabled?

      person.has_nino == 'yes'
    end

    def applicant
      @applicant ||= current_crime_application.applicant
    end

    def partner
      @partner ||= current_crime_application.partner
    end

    def benefit_check_recipient
      return partner if partner&.has_passporting_benefit?

      applicant
    end
  end
  # rubocop:enable Metrics/ClassLength
end
