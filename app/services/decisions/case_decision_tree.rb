module Decisions
  class CaseDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :urn
        edit(:case_type)
      when :case_type
        edit(:has_codefendants)
      when :has_codefendants
        after_has_codefendants
      when :add_codefendant
        edit_codefendants(add_blank: true)
      when :delete_codefendant
        edit_codefendants
      when :codefendants_finished
        after_codefendants
      when :charges
        edit(:charges_summary)
      when :add_offence_date
        after_add_offence_date
      when :delete_offence_date
        after_delete_offence_date
      when :charges_summary
        after_charges_summary
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    private

    def after_has_codefendants
      if form_object.has_codefendants.yes?
        edit_codefendants
      else
        after_codefendants
      end
    end

    def edit_codefendants(add_blank: false)
      codefendants = form_object.case.codefendants
      codefendants.create! if add_blank || codefendants.empty?

      edit(:codefendants)
    end

    def after_codefendants
      return edit(:charges_summary) if case_charges.any?

      edit_new_charge
    end

    def after_add_offence_date
      charge = form_object.record
      charge.offence_dates << OffenceDate.new if blank_date_required?(charge)
      edit(:charges, charge_id: charge)
    end

    def after_delete_offence_date
      charge = form_object.record
      edit(:charges, charge_id: charge)
    end

    def after_charges_summary
      # TODO: update when we have next step
      return show('/home', action: :index) if form_object.add_offence.no?

      edit_new_charge
    end

    def edit_new_charge
      charge = case_charges.create!(
        offence_dates_attributes: { id: nil } # a blank, first date
      )

      edit(:charges, charge_id: charge)
    end

    def case_charges
      @case_charges ||= form_object.case.charges
    end

    def blank_date_required?(charge)
      charge.offence_dates.map(&:date).exclude?(nil)
    end
  end
end
