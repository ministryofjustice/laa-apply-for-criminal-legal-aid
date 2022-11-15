class MockBenefitCheckService
  KNOWN = {
    'SMITH' => { nino: 'NC123459A', dob: '11-Jan-1999' },
    'JONES' => { nino: 'NC123458A', dob: '1-Jun-1980' },
    'BLOGGS' => { nino: 'NC123457A', dob: '4-Jan-1990' },
    'WRINKLE' => { nino: 'NC010150A', dob: '01-Jan-1950' },
    'WALKER' => { nino: 'JA293483A', dob: '10-Jan-1980' }, # Used in cucumber tests and specs
    'POTTER' => { nino: 'NC010155A', dob: '01-Jan-2007' }, # For under 18 passported on IOJ testing
  }.freeze

  def self.call(*args)
    new(*args).call
  end

  def self.passporting_benefit?(*args)
    new(*args).call[:benefit_checker_status].casecmp('yes').zero?
  end

  attr_reader :applicant

  delegate :last_name, :nino, :date_of_birth, to: :applicant, allow_nil: true

  def initialize(applicant)
    @applicant = applicant
  end

  def call
    {
      confirmation_ref: "mocked:#{self.class}",
      benefit_checker_status: result,
    }
  end

  def result
    known? ? 'Yes' : 'No'
  end

  def known?
    key = last_name.to_s.upcase
    return unless KNOWN.key?(key)

    KNOWN[key] == applicant_data
  end

  def applicant_data
    {
      nino: nino,
      dob: date_of_birth&.strftime('%d-%b-%Y'),
    }
  end
end
