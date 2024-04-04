module Decisions
  # rubocop:disable Metrics/ClassLength
  class CaseDecisionTree < BaseDecisionTree
    def destination # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      case step_name
      when :urn
        FeatureFlags.means_journey.enabled? ? edit(:has_case_concluded) : charges_summary_or_edit_new_charge
      when :has_case_concluded
        after_has_case_concluded
      when :is_preorder_work_claimed
        edit(:is_client_remanded)
      when :is_client_remanded
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
      when :first_court_hearing
        after_first_court_hearing
      when :ioj, :ioj_passport
        after_ioj
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_has_case_concluded
      return edit(:is_client_remanded) if form_object.has_case_concluded.no?

      edit(:is_preorder_work_claimed)
    end

    def charges_summary_or_edit_new_charge
      return edit(:charges_summary) if case_charges.any?(&:complete?)

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
      return edit_codefendants if form_object.has_codefendants.yes?

      edit(:hearing_details)
    end

    def edit_codefendants(add_blank: false)
      codefendants = form_object.case.codefendants
      codefendants.create! if add_blank || codefendants.empty?

      edit(:codefendants)
    end

    def after_hearing_details
      return edit(:first_court_hearing) if form_object.is_first_court_hearing.no?

      ioj_or_passported
    end

    def after_first_court_hearing
      ioj_or_passported
    end

    def means_test_required?
      applicant.has_benefit_evidence == 'no' || applicant.benefit_type == 'none'
    end

    def ioj_or_passported
      if Passporting::IojPassporter.new(current_crime_application).call
        edit(:ioj_passport)
      else
        edit(:ioj)
      end
    end

    def after_ioj
      return edit('/steps/income/employment_status') if means_test_required?

      return edit('/steps/evidence/upload') if evidence_upload_required?

      edit('/steps/submission/more_information')
    end

    def evidence_upload_required?
      Evidence::Requirements.new(current_crime_application).any? &&
        !Passporting::MeansPassporter.new(current_crime_application).call
    end

    def edit_new_charge
      charge = incomplete_charges.present? ? incomplete_charges.first : case_charges.create!

      edit(:charges, charge_id: charge)
    end

    def incomplete_charges
      case_charges.reject(&:complete?)
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

    def applicant
      @applicant ||= current_crime_application.applicant
    end
  end
  # rubocop:enable Metrics/ClassLength
end
