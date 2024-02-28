module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength
      case step_name
      when :housing_payment_type
        # TODO: determine and link to next step when we have it
        edit(:council_tax)
      when :council_tax
        edit(:outgoings_payments)
      when :outgoings_payments
        edit(:income_tax_rate)
      when :income_tax_rate
        edit(:outgoings_more_than_income)
      when :outgoings_more_than_income
        edit('/steps/capital/property_type')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
