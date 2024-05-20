class BaseAnswerValidator
  def initialize(record: nil, crime_application: nil)
    @record = record
    @crime_application = crime_application || record.crime_application
  end

  attr_reader :record, :crime_application

  delegate :errors, to: :record

  # :nocov:
  def applicable?
    raise 'implement in task subclasses'
  end

  def complete?
    raise 'implement in task subclasses'
  end

  def validate
    raise 'implement in task subclasses'
  end
  # :nocov:
end
