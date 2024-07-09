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
        after_business_financials
      when :business_salary_or_remuneration
        edit(:business_total_income_share_sales, business_id: form_object.record)
      when :business_total_income_share_sales
        edit(:business_percentage_profit_share, business_id: form_object.record)
      when :business_percentage_profit_share
        edit(:businesses_summary, business_id: form_object.record)
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

    def after_business_financials
      if form_object.record.business_type == BusinessType::DIRECTOR_OR_SHAREHOLDER.to_s
        edit(:business_salary_or_remuneration, business_id: form_object.record)
      elsif form_object.record.business_type == BusinessType::PARTNERSHIP.to_s
        edit(:business_percentage_profit_share, business_id: form_object.record)
      else
        edit(:businesses_summary, business_id: form_object.record)
      end
    end
  end
end
