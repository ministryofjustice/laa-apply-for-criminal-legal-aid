class NinoValidator < ActiveModel::Validator
  attr_reader :record

  NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

  def validate(record)
    blank_nino(record)
    bad_nino(record)
  end

  def blank_nino(record)
    return if record.nino.present?
    return if applicant_not_means_tested?(record)

    record.errors.add(:nino, :blank)
  end

  def bad_nino(record)
    return if record.nino.blank?
    return if NINO_REGEXP.match?(record.nino)

    record.errors.add(:nino, :invalid)
  end

  def applicant_not_means_tested?(record)
    return false unless record.class.respond_to?(:association_name)

    record.class.association_name == :applicant && record.crime_application.not_means_tested?
  end
end
