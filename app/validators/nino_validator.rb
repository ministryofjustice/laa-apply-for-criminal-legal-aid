class NinoValidator < ActiveModel::Validator
  attr_reader :record

  NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

  def validate(record)
    record.errors.add(:nino, :blank) if record.nino.blank?
    record.errors.add(:nino, :invalid) unless NINO_REGEXP.match?(record.nino)
  end
end
