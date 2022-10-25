class MockBenefitCheckService
  KNOWN = {
    'SMITH' => { nino: 'NC123459A', dob: '11-Jan-99' },
    'JONES' => { nino: 'NC123458A', dob: '1-Jun-80' },
    'BLOGGS' => { nino: 'NC123457A', dob: '4-Jan-90' },
    'WRINKLE' => { nino: 'NC010150A', dob: '01-Jan-50' },
    'WALKER' => { nino: 'JA293483A', dob: '10-Jan-80' }, # Used in cucumber tests and specs
  }.freeze

  def self.call(*args)
    new(*args).call
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
      dob: date_of_birth&.strftime('%d-%b-%y'),
    }
  end
end
