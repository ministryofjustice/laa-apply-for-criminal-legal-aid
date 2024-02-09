class PseFulfilmentValidator < BaseFulfilmentValidator
  private

  def perform_validations
    errors = []

    unless evidence_present?
      errors << [
        :documents, :blank, { change_path: edit_steps_evidence_upload_path }
      ]
    end

    errors
  end
end
