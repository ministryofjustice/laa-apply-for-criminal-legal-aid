module DWP
  class MockBenefitCheckService
    CONFIRMED = {
      'SMITH'   => { nino: 'NC123459A', dob: '11-01-1999' },
      'JONES'   => { nino: 'NC123458A', dob: '01-06-1980' },
      'BLOGGS'  => { nino: 'NC123457A', dob: '04-01-1990' },
      'WRINKLE' => { nino: 'NC010150A', dob: '01-01-1950' },
      'WALKER'  => { nino: 'JA293483A', dob: '10-01-1980' },
    }.freeze

    NOT_IN_RECEIPT = {
      'BROWN'   => { nino: 'PA435162A', dob: '01-07-1986' },
    }.freeze

    def self.call(*)
      new(*).call
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
      if known_confirmed?
        'Yes'
      else
        not_in_receipt? ? 'No' : 'Undetermined'
      end
    end

    private

    def known_confirmed?
      CONFIRMED.fetch(last_name.to_s.upcase, nil) == applicant_data
    end

    def not_in_receipt?
      NOT_IN_RECEIPT.fetch(last_name.to_s.upcase, nil) == applicant_data
    end

    def applicant_data
      {
        nino: nino,
        dob: date_of_birth&.strftime('%d-%m-%Y'),
      }
    end
  end
end
