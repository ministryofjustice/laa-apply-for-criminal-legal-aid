module Decisions
  class SelfEmployedIncomeDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      case step_name
      when :business_type
        edit(:businesses, business_id:)
      when :businesses_summary
        after_businesses_summary
      when :businesses
        edit(:business_nature, business_id:)
      when :business_nature
        edit(:business_start_date, business_id:)
      when :business_start_date
        edit(:business_additional_owners, business_id:)
      when :business_additional_owners
        edit(:business_employees, business_id:)
      when :business_employees
        edit(:business_financials, business_id:)
      when :business_financials
        edit(:businesses_summary, business_id:)
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def business_id
      form_object.record
    end

    def after_businesses_summary
      return edit(:business_type) if form_object.add_business.yes?

      person = form_object.subject.to_param
      edit("steps/income/#{person}/self_assessment_tax_bill")
    end
  end
end
