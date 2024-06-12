require 'rails_helper'

# This spec is just a high level, smoke test of the sections.
# It is not intended to test conditionality or complex rules,
# as that is tested individually in each of the sections specs.
#
describe Summary::HtmlPresenter do
  subject(:presenter) { described_class.new(crime_application:) }

  # rubocop:disable Layout/LineLength
  let(:database_application) do
    instance_double(
      CrimeApplication, applicant: (double benefit_type: 'universal_credit', has_partner: 'yes'), partner: (double Partner),
      kase: (double case_type: 'either_way'), ioj: double, status: :in_progress,
      income: (double partner_employment_status: [EmploymentStatus::NOT_WORKING.to_s], applicant_other_work_benefit_received: nil, has_no_income_payments: nil, has_no_income_benefits: nil),
      income_payments: [instance_double(IncomePayment, ownership_type: 'applicant', payment_type: 'maintenance'), instance_double(IncomePayment, ownership_type: 'partner', payment_type: 'maintenance')],
      outgoings_payments: [instance_double(OutgoingsPayment, payment_type: 'childcare')],
      income_benefits: [instance_double(IncomeBenefit, ownership_type: 'applicant', payment_type: 'incapacity'), instance_double(IncomeBenefit, ownership_type: 'partner', payment_type: 'jsa')],
      outgoings: (double has_no_other_outgoings: nil, applicant_self_assessment_tax_bill: nil),
      documents: double, application_type: application_type,
      capital: (double has_premium_bonds: 'yes', will_benefit_from_trust_fund: 'yes', partner_will_benefit_from_trust_fund: 'yes', has_no_properties: nil, has_no_savings: nil, has_no_investments: nil, has_national_savings_certificates: 'yes'),
      savings: [double], investments: [double], national_savings_certificates: [double], properties: [double]
    )
  end
  # rubocop:enable Layout/LineLength

  let(:datastore_application) do
    extra = {
      'means_details' => {
        'income_details' => {
          'employments' => [
            {
              'employer_name' => 'Joe Goodwin',
              'job_title' => 'Supervisor',
              'has_no_deductions' => nil,
              'address' => { 'address_line_one' => 'address_line_one_y',
                             'address_line_two' => 'address_line_two_y',
                             'city' => 'city_y',
                             'country' => 'country_y',
                             'postcode' => 'postcode_y' },
              'amount' => 25_000,
              'frequency' => 'annual',
              'ownership_type' => 'applicant',
              'metadata' => { 'before_or_after_tax' => { 'value' => 'before_tax' } },
              'deductions' => [
                {
                  'deduction_type' => 'income_tax',
                  'amount' => 1000,
                  'frequency' => 'week',
                  'details' => nil
                },
                {
                  'deduction_type' => 'national_insurance',
                  'amount' => 2000,
                  'frequency' => 'fortnight',
                  'details' => nil
                },
                {
                  'deduction_type' => 'other',
                  'amount' => 3000,
                  'frequency' => 'annual',
                  'details' => 'deduction details'
                }
              ]
            }
          ],
          'income_payments' => [
            {
              'payment_type' => 'maintenance',
              'amount' => 10_000,
              'frequency' => 'week',
              'ownership_type' => 'applicant'
            },
            {
              'payment_type' => 'maintenance',
              'amount' => 20_000,
              'frequency' => 'annual',
              'ownership_type' => 'partner'
            },
          ],
          'income_benefits' => [
            {
              'payment_type' => 'child',
              'amount' => 50_000,
              'frequency' => 'month',
              'ownership_type' => 'applicant'
            },
            {
              'payment_type' => 'other',
              'amount' => 1_000,
              'frequency' => 'month',
              'ownership_type' => 'partner',
              'metadata' => { 'details' => 'Local grant' },
            },
          ],
          'outgoings_payments' => [{
            'payment_type' => 'childcare',
            'amount' => 200,
            'frequency' => 'month',
            'ownership_type' => 'applicant_and_partner'
          }],
        },
        'capital_details' => {
          'savings' => [{ 'saving_type' => 'bank',
                          'provider_name' => 'Test Bank',
                          'ownership_type' => 'applicant',
                          'sort_code' => '01-01-01',
                          'account_number' => '01234500',
                          'account_balance' => 10_001,
                          'is_overdrawn' => 'yes',
                          'are_wages_paid_into_account' => 'yes' }],
          'investments' => [{ 'investment_type' => 'share_isa',
                          'description' => 'About my ISA',
                          'value' => 10_001,
                          'ownership_type' => 'applicant_and_partner' }],
          'national_savings_certificates' => [{ 'holder_number' => '1a',
                          'certificate_number' => '2b',
                          'value' => 121,
                          'ownership_type' => 'partner' }],
          'properties' => [{ 'property_type' => 'residential',
                             'house_type' => 'other',
                             'other_house_type' => 'other house type',
                             'size_in_acres' => 100,
                             'usage' => 'usage details',
                             'bedrooms' => 2,
                             'value' => 200_000,
                             'outstanding_mortgage' => 100_000,
                             'percentage_applicant_owned' => 80.01,
                             'percentage_partner_owned' => 20.01,
                             'is_home_address' => 'yes',
                             'has_other_owners' => 'no',
                             'address' => nil, 'property_owners' => [] }],
          'has_premium_bonds' => 'yes',
          'premium_bonds_total_value' => 1234,
          'premium_bonds_holder_number' => '1234A',
          'will_benefit_from_trust_fund' => 'yes',
          'trust_fund_amount_held' => 1000,
          'trust_fund_yearly_dividend' => 2000
        }
      },
      'application_type' => application_type,
      'case_details' => { 'case_type' => 'either_way' }
    }

    JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(extra)
  end

  describe '#sections' do
    subject(:sections) { presenter.sections.map { |s| s.class.name.demodulize } }

    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      context 'for an "in progress" database application' do
        let(:crime_application) { database_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            ContactDetails
            PartnerDetails
            PassportingBenefitCheck
            PassportingBenefitCheckPartner
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            Employments
            Dependants
            PartnerEmploymentDetails
            IncomePaymentsDetails
            IncomeBenefitsDetails
            PartnerIncomePaymentsDetails
            PartnerIncomeBenefitsDetails
            OtherIncomeDetails
            HousingPayments
            OutgoingsPaymentsDetails
            OtherOutgoingsDetails
            Savings
            Properties
            PremiumBonds
            NationalSavingsCertificates
            Investments
            TrustFund
            PartnerTrustFund
            OtherCapitalDetails
            SupportingEvidence
            MoreInformation
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end

      context 'for a "submitted" datastore application' do
        let(:crime_application) { datastore_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            ContactDetails
            PartnerDetails
            PassportingBenefitCheck
            PassportingBenefitCheckPartner
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            Employments
            PartnerEmploymentDetails
            IncomePaymentsDetails
            IncomeBenefitsDetails
            Dependants
            PartnerIncomePaymentsDetails
            PartnerIncomeBenefitsDetails
            OtherIncomeDetails
            HousingPayments
            OutgoingsPaymentsDetails
            OtherOutgoingsDetails
            Savings
            Properties
            PremiumBonds
            NationalSavingsCertificates
            Investments
            TrustFund
            PartnerTrustFund
            OtherCapitalDetails
            SupportingEvidence
            MoreInformation
            LegalRepresentativeDetails
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end
    end

    context 'when a PSE application' do
      let(:application_type) { 'post_submission_evidence' }

      context 'for an "in progress" database application' do
        let(:crime_application) { database_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            SupportingEvidence
            MoreInformation
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end

      context 'for a "submitted" datastore application' do
        let(:crime_application) { datastore_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            SupportingEvidence
            MoreInformation
            LegalRepresentativeDetails
          ]
        end

        it { is_expected.to match_array(expected_sections) }
      end
    end
  end

  describe '#capital_sections' do
    subject(:capital_sections) { presenter.capital_sections.map { |s| s.class.name.demodulize } }

    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    let(:crime_application) { database_application }

    expected_sections = %w[
      Investments
      NationalSavingsCertificates
      OtherCapitalDetails
      PremiumBonds
      Properties
      Savings
      TrustFund
      PartnerTrustFund
    ]

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      it { is_expected.to match_array(expected_sections) }
    end

    context 'when a PSE application' do
      let(:application_type) { 'post_submission_evidence' }

      it { is_expected.to match_array(expected_sections) }
    end
  end

  describe '#outgoings_sections' do
    subject(:outgoings_sections) { presenter.outgoings_sections.map { |s| s.class.name.demodulize } }

    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    let(:crime_application) { database_application }

    expected_sections = %w[
      HousingPayments
      OutgoingsPaymentsDetails
      OtherOutgoingsDetails
    ]

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      it { is_expected.to match_array(expected_sections) }
    end
  end

  describe '#income_sections' do
    subject(:income_sections) { presenter.income_sections.map { |s| s.class.name.demodulize } }

    before do
      allow_any_instance_of(
        Summary::Sections::BaseSection
      ).to receive(:show?).and_return(true)
    end

    let(:crime_application) { database_application }

    expected_sections = %w[
      EmploymentDetails
      IncomeDetails
      Employments
      IncomePaymentsDetails
      IncomeBenefitsDetails
      Dependants
      PartnerIncomePaymentsDetails
      PartnerIncomeBenefitsDetails
      PartnerEmploymentDetails
      OtherIncomeDetails
    ]

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      it { is_expected.to match_array(expected_sections) }
    end
  end
end
