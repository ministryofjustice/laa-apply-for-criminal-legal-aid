module TypeOfEmployment
  extend ActiveSupport::Concern

  delegate :income, to: :crime_application

  def not_working?
    income.employment_status.include?(EmploymentStatus::NOT_WORKING.to_s)
  end

  def employed?
    income.employment_status.include?(EmploymentStatus::EMPLOYED.to_s)
  end

  def ended_employment_within_three_months?
    income.ended_employment_within_three_months == 'yes'
  end
end
