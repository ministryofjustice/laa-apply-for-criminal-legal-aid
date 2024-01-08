module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :housing_payment_type
        edit(:council_tax)
      when :council_tax
        # TODO: link to next step when we have it
        edit(:income_tax_rate)
      when :income_tax_rate
        edit(:outgoings_more_than_income)
      when :outgoings_more_than_income
        # TODO: link to next step when we have it
        show('/home', action: :index)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
  end
end
