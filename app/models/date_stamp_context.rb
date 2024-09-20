class DateStampContext
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :date_of_birth, :date

  attribute :date_stamp, :datetime
  attribute :created_at, :datetime

  def self.build(crime_application, date_stamp = Time.current)
    DateStampContext.new(
      first_name: crime_application.applicant&.first_name,
      last_name: crime_application.applicant&.last_name,
      date_of_birth: crime_application.applicant&.date_of_birth,
      date_stamp: date_stamp,
      created_at: DateTime.now,
    )
  end
end
