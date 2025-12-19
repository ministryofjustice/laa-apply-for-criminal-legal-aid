module Decisions
  # rubocop:disable Metrics/ClassLength
  class CaseDecisionTree < BaseDecisionTree
    include TypeOfMeansAssessment

    def destination # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
      case step_name
      when :urn
        edit(:has_case_concluded)
      when :has_case_concluded
        after_has_case_concluded
      when :is_preorder_work_claimed
        determine_showing_client_remanded
      when :is_client_remanded
        charges_summary_or_edit_new_charge
      when :charges
        edit(:charges_dates)
      when :charges_dates
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
        after_codefendants_finished
      when :other_charge_in_progress
        after_other_charge_in_progress
      when :other_charge
        after_other_charge
      when :hearing_details
        after_hearing_details
      when :first_court_hearing
        ioj_or_passported
      when :ioj, :ioj_passport
        after_ioj
      else
        raise InvalidStep, "Invalid step '#{step_name}'"
      end
    end

    private

    def after_has_case_concluded
      return determine_showing_client_remanded if form_object.has_case_concluded.no?

      edit(:is_preorder_work_claimed)
    end

    def determine_showing_client_remanded
      return charges_summary_or_edit_new_charge if not_means_tested?

      edit(:is_client_remanded)
    end

    def charges_summary_or_edit_new_charge
      return after_ioj if form_object.crime_application.cifc?
      return edit(:charges_summary) if case_charges.any?(&:complete?)

      edit_new_charge
    end

    def after_add_offence_date
      current_charge.offence_dates << OffenceDate.new if blank_date_required?
      edit(:charges_dates, charge_id: current_charge)
    end

    def after_delete_offence_date
      edit(:charges_dates, charge_id: current_charge)
    end

    def after_charges_summary
      return edit(:has_codefendants) if form_object.add_offence.no?

      edit_new_charge
    end

    def after_has_codefendants
      return edit_codefendants if form_object.has_codefendants.yes?
      return edit(:other_charge_in_progress, subject: 'client') if require_other_charge_in_progress?('client')

      edit(:hearing_details)
    end

    def after_codefendants_finished
      return edit(:other_charge_in_progress, subject: 'client') if require_other_charge_in_progress?('client')

      edit(:hearing_details)
    end

    def edit_codefendants(add_blank: false)
      codefendants = form_object.case.codefendants
      codefendants.create! if add_blank || codefendants.empty?

      edit(:codefendants)
    end

    def after_other_charge_in_progress
      subject = form_object.form_subject.to_param.to_s
      return edit(:other_charge, subject:) if require_other_charge?(subject)

      progress_from_other_charge(subject)
    end

    def after_other_charge
      subject = form_object.form_subject.to_param.to_s

      progress_from_other_charge(subject)
    end

    def progress_from_other_charge(subject)
      case subject
      when 'client'
        if require_other_charge_in_progress?('partner')
          edit(:other_charge_in_progress, subject: 'partner')
        else
          edit(:hearing_details)
        end
      when 'partner' then edit(:hearing_details)
      end
    end

    def after_hearing_details
      return edit(:first_court_hearing) if form_object.is_first_court_hearing.no?

      ioj_or_passported
    end

    def ioj_or_passported
      if Passporting::IojPassporter.new(crime_application).call
        edit(:ioj_passport)
      else
        edit(:ioj)
      end
    end

    def after_ioj
      if requires_means_assessment?
        edit('/steps/income/employment_status')
      else
        edit('/steps/evidence/upload')
      end
    end

    def edit_new_charge
      charge = incomplete_charges.present? ? incomplete_charges.first : case_charges.create!

      edit(:charges, charge_id: charge)
    end

    def incomplete_charges
      case_charges.reject(&:complete?)
    end

    def case_charges
      @case_charges ||= crime_application.case.charges
    end

    def current_charge
      @current_charge ||= form_object.record
    end

    def blank_date_required?
      current_charge.offence_dates.map(&:date_from).exclude?(nil)
    end

    def require_other_charge_in_progress?(subject)
      kase.send(:"require_#{subject}_other_charge_in_progress?")
    end

    def require_other_charge?(subject)
      kase.send(:"require_#{subject}_other_charge?")
    end

    def crime_application
      form_object.crime_application
    end
  end
  # rubocop:enable Metrics/ClassLength
end
