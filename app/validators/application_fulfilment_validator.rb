class ApplicationFulfilmentValidator < BaseFulfilmentValidator
  include TypeOfMeansAssessment

  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  def perform_validations # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    errors = []

    unless means_valid?
      errors << [
        :means_passport, :blank, { change_path: edit_steps_client_details_path }
      ]
    end

    if record.is_means_tested == 'yes' && kase.case_type.nil?
      errors << [
        :base, :case_type_missing, { change_path: edit_steps_client_case_type_path }
      ]
    end

    unless ioj_present? || Passporting::IojPassporter.new(record).call
      errors << [
        :ioj_passport, :blank, { change_path: edit_steps_case_ioj_path }
      ]
    end

    unless evidence_upload_complete?
      errors << [
        :documents, :blank, { change_path: edit_steps_evidence_upload_path }
      ]
    end

    unless cifc_reference_complete?
      errors << [
        :base, :circumstances_reference, { change_path: edit_steps_circumstances_pre_cifc_reference_number_path }
      ]
    end

    unless cifc_reason_complete?
      errors << [
        :base, :circumstances_reason, { change_path: edit_steps_circumstances_pre_cifc_reason_path }
      ]
    end

    errors
  end

  def means_valid?
    return true if record.cifc?
    return true if Passporting::MeansPassporter.new(record).call
    return true if appeal_no_changes?

    evidence_present? || means_record_present? || client_remanded_in_custody?
  end

  def ioj_present?
    return true if crime_application.cifc?

    record.ioj.present? && record.ioj.types.any?
  end

  def means_record_present?
    income.present? && income&.employment_status.present?
  end

  def client_remanded_in_custody?
    kase.is_client_remanded == 'yes' && kase.date_client_remanded.present?
  end

  def evidence_validator
    ::SupportingEvidence::AnswersValidator.new(record:, crime_application:)
  end

  def evidence_upload_complete?
    return true unless evidence_validator.applicable?

    evidence_validator.evidence_complete?
  end

  def circumstances_validator
    ::Circumstances::AnswersValidator.new(record:, crime_application:)
  end

  def cifc_reference_complete?
    circumstances_validator.circumstances_reference_complete?
  end

  def cifc_reason_complete?
    circumstances_validator.circumstances_reason_complete?
  end

  alias crime_application record
end
