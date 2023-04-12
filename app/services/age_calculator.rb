class AgeCalculator
  attr_reader :person

  def initialize(person)
    @person = person
  end

  def under18?
    dob = person.date_of_birth
    dob + 18.years > Time.zone.today
  end
end
