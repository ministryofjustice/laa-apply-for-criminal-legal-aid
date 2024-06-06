class ApplicationFulfilmentValidator < BaseFulfilmentValidator
  include TypeOfMeansAssessment

  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  def perform_validations # rubocop:disable Metrics/MethodLength
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

    unless Passporting::IojPassporter.new(record).call || ioj_present?
      errors << [
        :ioj_passport, :blank, { change_path: edit_steps_case_ioj_path }
      ]
    end

    errors
  end

  def means_valid?
    return true if Passporting::MeansPassporter.new(record).call

    evidence_present? || means_record_present? || client_remanded_in_custody?
  end

  def ioj_present?
    record.ioj.present? && record.ioj.types.any?
  end

  def means_record_present?
    if FeatureFlags.employment_journey.enabled?
      # TODO: Update definition
      income.present? && income&.employment_status.present?
    else
      income.present? && income&.employment_status&.include?('not_working')
    end
  end

  def client_remanded_in_custody?
    kase.is_client_remanded == 'yes' && kase.date_client_remanded.present?
  end

  alias crime_application record
end
