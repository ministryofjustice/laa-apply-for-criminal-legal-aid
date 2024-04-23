module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    include TypeOfMeansAssessment

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
      if requires_full_capital?
        edit('/steps/capital/property_type')
      else
        edit('/steps/capital/trust_fund')
      end
    end

    def crime_application
      form_object.crime_application
    end
  end
end
