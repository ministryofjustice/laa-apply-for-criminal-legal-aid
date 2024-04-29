module PersonWithDob
  extend ActiveSupport::Concern

  def under18?
    if date_of_birth.blank?
      raise DateOfBirthPending, 'Cannot determine under18 because date of birth is not set'
    end

    date_of_birth + 18.years > Time.zone.today
  end
end
