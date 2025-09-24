class Case < ApplicationRecord
  include HasOtherCharges

  belongs_to :crime_application, touch: true

  EARLIEST_HEARING_DATE = Date.parse('01-01-2010')
  LATEST_HEARING_DATE = Date.parse('31-12-2035')

  has_one :ioj, dependent: :destroy
  has_many :codefendants, dependent: :destroy
  accepts_nested_attributes_for :codefendants, allow_destroy: true

  has_many :charges, dependent: :destroy,
           before_add: [:initialise_dates] do
    def complete
      select(&:complete?)
    end
  end

  composed_of :hearing_court, class_name: 'Court',
              mapping: %i[hearing_court_name name],
              constructor: :find_by_name, allow_nil: true

  validate on: :submission do
    CaseDetails::AnswersValidator.new(self).validate
  end

  def complete?
    valid?(:submission)
  end

  def hearing_date_within_range?
    hearing_date.between?(EARLIEST_HEARING_DATE, LATEST_HEARING_DATE)
  end

  private

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end
end
