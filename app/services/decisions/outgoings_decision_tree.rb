module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
      case step_name
      when :housing_payment_type
        after_housing_payment_type
      when :mortgage, :rent
        edit(:council_tax)
      when :board_and_lodging, :council_tax
        edit(:outgoings_payments)
      when :outgoings_payments
        edit(:income_tax_rate)
      when :income_tax_rate
        edit(:outgoings_more_than_income)
      when :outgoings_more_than_income
        edit(:answers)
      when :answers
        after_answers
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_housing_payment_type
      case form_object.housing_payment_type&.value
      when :board_and_lodging, :mortgage, :rent
        edit(form_object.housing_payment_type.value)
      when nil, :none
        edit(:council_tax)
      end
    end

    def after_answers
      if requires_full_capital
        return edit('/steps/capital/clients_assets') if current_crime_application.properties.present?

        edit('/steps/capital/property_type')
      else
        edit('/steps/capital/trust_fund')
      end
    end

    def requires_full_capital
      [
        CaseType::EITHER_WAY.to_s,
        CaseType::INDICTABLE.to_s,
        CaseType::ALREADY_IN_CROWN_COURT.to_s
      ].include?(case_type)
    end

    def case_type
      current_crime_application.case.case_type
    end
  end
end
