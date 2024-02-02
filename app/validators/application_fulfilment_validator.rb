class ApplicationFulfilmentValidator < BaseFulfilmentValidator
  private

  # More validations can be added here
  # Errors, when more than one, will maintain the order
  def perform_validations # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    errors = []

    unless Passporting::MeansPassporter.new(record).call || evidence_present?
      errors << [
        :means_passport, :blank, { change_path: edit_steps_client_details_path }
      ]
    end

    if record.case.case_type.nil? && record.is_means_tested == 'yes'
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

  def ioj_present?
    record.ioj.present? && record.ioj.types.any?
  end
end
