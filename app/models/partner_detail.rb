class PartnerDetail < ApplicationRecord
  belongs_to :crime_application, touch: true

  validate on: :submission do
    answers_validator.validate
  end

  def self.fields
    PartnerDetail.column_names - %w[id crime_application_id updated_at created_at]
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= PartnerDetails::AnswersValidator.new(record: self)
  end
end
