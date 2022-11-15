module Decisions
  class CaseDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :urn
        edit(:case_type)
      when :case_type
        after_case_type
      when :date_stamp
        charges_summary_or_edit_new_charge
      when :charges
        edit(:charges_summary)
      when :add_offence_date
        after_add_offence_date
      when :delete_offence_date
        after_delete_offence_date
      when :charges_summary
        after_charges_summary
      when :has_codefendants
        after_has_codefendants
      when :add_codefendant
        edit_codefendants(add_blank: true)
      when :delete_codefendant
        edit_codefendants
      when :codefendants_finished
        edit(:hearing_details)
      when :hearing_details
        after_hearing_details
      when :ioj, :ioj_passport
        edit('/steps/submission/review')
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_case_type
      if DateStamper.new(form_object.crime_application, form_object.case.case_type).call
        edit(:date_stamp)
      else
        charges_summary_or_edit_new_charge
      end
    end

    def charges_summary_or_edit_new_charge
      return edit(:charges_summary) if case_charges.any?

      edit_new_charge
    end

    def after_add_offence_date
      current_charge.offence_dates << OffenceDate.new if blank_date_required?
      edit(:charges, charge_id: current_charge)
    end

    def after_delete_offence_date
      edit(:charges, charge_id: current_charge)
    end

    def after_charges_summary
      return edit(:has_codefendants) if form_object.add_offence.no?

      edit_new_charge
    end

    def after_has_codefendants
      if form_object.has_codefendants.yes?
        edit_codefendants
      else
        edit(:hearing_details)
      end
    end

    def edit_codefendants(add_blank: false)
      codefendants = form_object.case.codefendants
      codefendants.create! if add_blank || codefendants.empty?

      edit(:codefendants)
    end

    def after_hearing_details
      if IojPassporter.new(form_object.crime_application.applicant, form_object.case).call
        edit(:ioj_passport)
      else
        edit(:ioj)
      end
    end

    def edit_new_charge
      charge = case_charges.create!
      edit(:charges, charge_id: charge)
    end

    def case_charges
      @case_charges ||= form_object.case.charges
    end

    def current_charge
      @current_charge ||= form_object.record
    end

    def blank_date_required?
      current_charge.offence_dates.map(&:date).exclude?(nil)
    end
  end
end
