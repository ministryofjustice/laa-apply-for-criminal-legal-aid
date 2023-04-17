module PersonWithDob
  extend ActiveSupport::Concern

  def under18?
    date_of_birth + 18.years > Time.zone.today
  end
end
