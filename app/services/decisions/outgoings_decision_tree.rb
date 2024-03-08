module Decisions
  class OutgoingsDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength
      case step_name
      when :housing_payment_type
        after_housing_payment_type
      when :board_and_lodging, :mortgage, :rent
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

    private

    def after_housing_payment_type # rubocop:disable Metrics/AbcSize
      if form_object.housing_payment_type.nil?
        # TODO: Consider appropriate action for empty housing_payment_type
        edit(:council_tax)
      elsif form_object.housing_payment_type.value == :board_and_lodging
        edit(:board_and_lodging)
      elsif form_object.housing_payment_type.value == :mortgage
        edit(:mortgage)
      elsif form_object.housing_payment_type.value == :rent
        edit(:rent)
      end
    end
  end
end
