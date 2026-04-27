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

  def appeal_lodged_date
    super if appeal_case_type?
  end

  def appeal_with_changes_details
    super if appeal_case_type?
  end

  def appeal_original_app_submitted
    super if appeal_case_type?
  end

  def appeal_reference_number
    super if appeal_case_type?
  end

  def appeal_financial_circumstances_changed
    super if appeal_original_app_submitted?
  end

  def appeal_maat_id
    super if original_application_reference_required?
  end

  def appeal_usn
    super if original_application_reference_required?
  end

  def appeal_case_type?
    return false unless case_type

    CaseType.new(case_type).appeal?
  end

  def appeal_original_app_submitted?
    appeal_original_app_submitted == 'yes'
  end

  def appeal_financial_circumstances_changed?
    appeal_financial_circumstances_changed == 'yes'
  end

  def hearing_date_within_range?
    hearing_date.between?(EARLIEST_HEARING_DATE, LATEST_HEARING_DATE)
  end

  private

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end

  def original_application_reference_required?
    appeal_financial_circumstances_changed == 'no'
  end
end
