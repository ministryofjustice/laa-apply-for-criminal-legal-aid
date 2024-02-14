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

  validates :date_case_concluded, presence: true, if: -> { case_concluded? }
  validates :date_client_remanded, presence: true, if: -> { client_remanded? }
  validates :preorder_work_date, :preorder_work_details, presence: true, if: -> { preorder_work_claimed? }

  composed_of :hearing_court, class_name: 'Court',
              mapping: %i[hearing_court_name name],
              constructor: :find_by_name, allow_nil: true

  private

  def case_concluded?
    has_case_concluded == YesNoAnswer::YES.to_s
  end

  def client_remanded?
    is_client_remanded == YesNoAnswer::YES.to_s
  end

  def preorder_work_claimed?
    is_preorder_work_claimed == YesNoAnswer::YES.to_s
  end

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end
end
