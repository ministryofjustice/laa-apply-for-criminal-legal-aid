class Income < ApplicationRecord
  belongs_to :crime_application
  has_many :income_payments, through: :crime_application
  has_many :income_benefits, through: :crime_application
  has_many :dependants, through: :crime_application

  validate on: :submission do
    answers_validator.validate
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= IncomeAssessment::AnswersValidator.new(self)
  end

  # Employment Statuses requiring self-assement
  # TODO: Shareholder requires self-assessment form?
  def self_assessment?
    assessable = [
      EmploymentStatus::SELF_EMPLOYED.to_s,
      EmploymentStatus::BUSINESS_PARTNERSHIP.to_s,
      EmploymentStatus::DIRECTOR.to_s,
      EmploymentStatus::SHAREHOLDER.to_s,
    ]

    assessable.intersect?(Array.wrap(employment_status))
  end
end
