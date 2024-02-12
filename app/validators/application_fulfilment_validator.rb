class ApplicationFulfilmentValidator < BaseFulfilmentValidator
  private

  def perform_validations
    errors = []

    unless Passporting::MeansPassporter.new(record).call || evidence_present?
      errors << [
        :means_passport, :blank, { change_path: edit_steps_client_details_path }
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
