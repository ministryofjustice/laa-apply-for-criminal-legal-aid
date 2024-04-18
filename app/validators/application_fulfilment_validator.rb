class ApplicationFulfilmentValidator < BaseFulfilmentValidator
  include TypeOfMeansAssessment

  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  def perform_validations # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    errors = []

    unless Passporting::MeansPassporter.new(record).call || evidence_present? ||
           means_record_present? || client_remanded_in_custody?
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

    unless all_sections_complete?
      errors << [
        :base, :incomplete_records, { change_path: edit_steps_submission_review_path }
      ]
    end

    errors
  end

  def ioj_present?
    record.ioj.present? && record.ioj.types.any?
  end

  def means_record_present?
    income.present? && income&.employment_status&.include?('not_working')
  end

  def client_remanded_in_custody?
    kase.is_client_remanded == 'yes' && kase.date_client_remanded.present?
  end

  def all_sections_complete?
    return false if requires_full_means_assessment? && !capital&.valid?(:submission)

    kase.valid?(:submission)
  end

  alias crime_application record
end
