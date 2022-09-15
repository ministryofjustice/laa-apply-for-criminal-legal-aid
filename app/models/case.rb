class Case < ApplicationRecord
  belongs_to :crime_application

  has_many :codefendants, dependent: :destroy
  accepts_nested_attributes_for :codefendants, allow_destroy: true

  has_many :charges, dependent: :destroy,
           before_add: [:initialise_dates]

  private

  def initialise_dates(charge)
    charge.offence_dates.build  # a blank, first date
  end
end
