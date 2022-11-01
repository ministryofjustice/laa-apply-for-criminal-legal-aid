class IojPassporter
  def initialize(applicant, kase)
    @applicant = applicant
    @case = kase
  end

  def call
    if applicant_age(@applicant.date_of_birth) < 18
      @case.update(ioj: Ioj.new({ types: ['passported'] }))
    else
      false
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def applicant_age(dob)
    years = Time.zone.now.year - dob.year
    years -= 1 if Time.zone.now.month < dob.month
    years -= 1 if Time.zone.now.month == dob.month && Time.zone.now.day < dob.day

    years
  end
  # rubocop:enable Metrics/AbcSize
end
