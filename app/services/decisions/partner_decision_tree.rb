module Decisions
  class PartnerDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength
    def destination
      case step_name
      when :relationship
        edit(:details)
      when :details
        edit(:involvement)
      when :involvement
        after_involvement
      when :conflict
        after_conflict
      when :nino
        edit(:same_address)
      when :same_address
        after_same_address
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def after_involvement
      if form_object.involvement_in_case == PartnerInvolvementType::CODEFENDANT
        edit(:conflict)
      elsif form_object.involvement_in_case == PartnerInvolvementType::NONE
        edit(:nino)
      else
        exit_partner_journey
      end
    end

    def after_conflict
      if form_object.conflict_of_interest.yes?
        exit_partner_journey
      else
        edit(:nino)
      end
    end

    def after_same_address
      if form_object.has_same_address_as_client.yes?
        exit_partner_journey
      else
        start_address_journey(HomeAddress)
      end
    end

    def start_address_journey(address_class)
      address = address_class.find_or_create_by(person: partner)

      edit('/steps/address/lookup', address_id: address)
    end

    def exit_partner_journey
      if current_crime_application.not_means_tested?
        edit('/steps/case/urn')
      else
        edit('/steps/dwp/benefit_type')
      end
    end
  end
end
