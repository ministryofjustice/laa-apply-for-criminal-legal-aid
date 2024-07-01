module PersonWithDob
  extend ActiveSupport::Concern

  # :nocov:
  def under18?
    raise Errors::DateOfBirthPending, 'date of birth is not set' if date_of_birth.blank?

    date_of_birth + 18.years > Time.zone.today
  end
  # :nocov:
end
