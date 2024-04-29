module PersonWithDob
  extend ActiveSupport::Concern

  def under18?
    raise DateOfBirthPending, 'Cannot determine under18 because date of birth is not set' if date_of_birth.blank?

    date_of_birth + 18.years > Time.zone.today
  end
end
