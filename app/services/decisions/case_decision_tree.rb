module Decisions
  # rubocop:disable Metrics/ClassLength
  class CaseDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def destination
      case step_name
      when :case_type
        after_case_type
      when :appeal_details
        date_stamp_if_needed
      when :date_stamp
        edit(:urn)
      when :urn
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
        after_ioj
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def after_case_type
      return edit(:appeal_details) if form_object.case_type.appeal?

      date_stamp_if_needed
    end

    def date_stamp_if_needed
      if DateStamper.new(form_object.crime_application, form_object.case.case_type).call
        edit(:date_stamp)
      else
        edit(:urn)
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
      if Passporting::IojPassporter.new(current_crime_application).call
        edit(:ioj_passport)
      else
        edit(:ioj)
      end
    end

    # NOTE: for MVP, this is the last step of the application,
    # however post-MVP there will be means assessment steps,
    # unless the applicant has been passported. As this is not
    # yet implemented, and for MVP we only let means passported
    # applicants, raise an exception (this should NOT happen but
    # in case it happens, we get alerted).
    #
    # rubocop:disable Style/GuardClause
    def after_ioj
      if Passporting::MeansPassporter.new(current_crime_application).call
        edit('/steps/submission/review')
      else
        # TODO: post-MVP implement means assessment steps
        # For MVP, this branch should not be reachable, and if
        # we end up here, we want to know about it (Sentry)
        raise InvalidStep, 'application is not means-passported'
      end
    end
    # rubocop:enable Style/GuardClause

    def edit_new_charge
      charge = case_charges.create!
      edit(:charges, charge_id: charge)
    end

    def case_charges
      @case_charges ||= current_crime_application.case.charges
    end

    def current_charge
      @current_charge ||= form_object.record
    end

    def blank_date_required?
      current_charge.offence_dates.map(&:date_from).exclude?(nil)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
