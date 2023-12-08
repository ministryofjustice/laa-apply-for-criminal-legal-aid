class Case < ApplicationRecord
  belongs_to :crime_application

  has_one :ioj, dependent: :destroy
  has_many :codefendants, dependent: :destroy
  accepts_nested_attributes_for :codefendants, allow_destroy: true

  has_many :dependants, dependent: :destroy
  accepts_nested_attributes_for :dependants, allow_destroy: true

  has_many :charges, dependent: :destroy,
           before_add: [:initialise_dates] do
    def complete
      select(&:complete?)
    end
  end

  composed_of :hearing_court, class_name: 'Court',
              mapping: %i[hearing_court_name name],
              constructor: :find_by_name, allow_nil: true

  private

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end
end
