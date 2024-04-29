class Case < ApplicationRecord
  belongs_to :crime_application

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

  validates_with CaseDetails::AnswersValidator, on: [:check_answers, :submission]

  def complete?
    case_hearing_attributes_present? &&
      case_concluded_attributes_present? &&
      client_remanded_attributes_present? &&
      preorder_work_attributes_present? &&
      all_codefendants_complete? &&
      all_charges_complete?
  end

  private

  def case_hearing_attributes_present?
    values_at(:hearing_court_name, :hearing_date).all?(&:present?)
  end

  def all_codefendants_complete?
    codefendants.all?(&:complete?)
  end

  def all_charges_complete?
    charges.all?(&:complete?)
  end

  def case_concluded_attributes_present?
    if has_case_concluded.nil? || has_case_concluded == YesNoAnswer::NO.to_s
      true
    elsif has_case_concluded == YesNoAnswer::YES.to_s
      values_at(:date_case_concluded).all?(&:present?)
    end
  end

  def preorder_work_attributes_present?
    if is_preorder_work_claimed.nil? || is_preorder_work_claimed == YesNoAnswer::NO.to_s
      true
    elsif is_preorder_work_claimed == YesNoAnswer::YES.to_s
      values_at(:preorder_work_date, :preorder_work_details).all?(&:present?)
    end
  end

  def client_remanded_attributes_present?
    if is_client_remanded.nil? || is_client_remanded == YesNoAnswer::NO.to_s
      true
    elsif is_client_remanded == YesNoAnswer::YES.to_s
      values_at(:date_client_remanded).all?(&:present?)
    end
  end

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end
end
