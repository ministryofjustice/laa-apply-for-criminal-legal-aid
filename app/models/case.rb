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

  # Temporarily, because some applications in datastore might
  # have this, now unused, attribute, to be able to re-hydrate
  alias_attribute :appeal_with_changes_maat_id, :appeal_maat_id

  private

  def initialise_dates(charge)
    charge.offence_dates.first_or_initialize
  end
end
