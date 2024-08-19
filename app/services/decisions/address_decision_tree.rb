module Decisions
  class AddressDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :lookup
        edit(:results)
      when :results, :details
        after_address_entered
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_address_entered
      if form_object.record.is_a?(HomeAddress)
        if form_object.record.person.is_a?(Partner)
          dwp_or_case_journey
        else
          edit('/steps/client/contact_details')
        end
      elsif current_crime_application.age_passported?
        edit('/steps/case/urn')
      else
        edit('/steps/client/has_nino')
      end
    end

    def dwp_or_case_journey
      if current_crime_application.applicant.arc.present? && current_crime_application.partner.arc.present?
        return edit('/steps/case/urn')
      end

      return edit('/steps/dwp/partner_benefit_type') if current_crime_application.applicant.arc.present?

      edit('/steps/dwp/benefit_type')
    end
  end
end
