RSpec.shared_context 'serializable application' do # rubocop:disable RSpec/MultipleMemoizedHelpers
  # This shared context provides a CrimeApplication aggregate interface,
  # allowing it to be configured using the same methods as MeansStatus and
  # TypeOfApplication etc. Instead of mocking and stubbing methods, it sets the
  # data directly.
  #
  # Consumers can configure the application with methods like
  # `let(:include_partner?) { false }`, rather than directly modifying the
  # partner record. This ensures consistent configuration across the
  # application using the same methods used by the code.

  let(:crime_application) do
    PartnerDetail.new(
      involvement_in_case: include_partner? ? 'none' : 'victim'
    )

    employment_status = []
    partner_employment_status = []

    employment_status << 'employed' if client_employed?
    employment_status << 'self_employed' if client_self_employed?
    partner_employment_status << 'employed' if partner_employed?
    partner_employment_status << 'self_employed' if partner_self_employed?

    income_above_threshold = full_means_required? ? 'yes' : 'no'

    income = Income.new(
      employment_status:,
      partner_employment_status:,
      income_above_threshold:
    )

    applicant = Applicant.new(
      date_of_birth: (age_passported? ? 17 : 30).years.ago
    )

    CrimeApplication.create(
      id: SecureRandom.uuid,
      income: income,
      case: Case.new(case_type:),
      income_payments: income_payments,
      income_benefits: income_benefits,
      savings: savings,
      investments: investments,
      national_savings_certificates: national_savings_certificates,
      outgoings: Outgoings.new,
      outgoings_payments: outgoings_payments,
      applicant: applicant,
      partner: Partner.new,
      capital: Capital.new,
      partner_detail: PartnerDetail.new(involvement_in_case: include_partner? ? 'none' : 'victim'),
      usn: 691_231,
      created_at: Time.zone.now
    )
  end

  let(:age_passported?) { false }
  let(:include_partner?) { true }
  let(:means_required?) { true }
  let(:full_means_required?) { true }
  let(:full_capital_required?) { true }

  let(:income_payments) { [] }
  let(:outgoings_payments) { [] }
  let(:income_benefits) { [] }
  let(:savings) { [] }
  let(:investments) { [] }
  let(:national_savings_certificates) { [] }

  let(:client_employed?) { false }
  let(:partner_employed?) { false }
  let(:client_self_employed?) { false }
  let(:partner_self_employed?) { false }

  let(:case_type) { full_capital_required? ? CaseType::INDICTABLE : CaseType::SUMMARY_ONLY }

  delegate :capital, :income, :outgoings, :applicant, :partner, to: :crime_application
end
