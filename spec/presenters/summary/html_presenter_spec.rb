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
      CrimeApplication, applicant: double, kase: (double case_type: 'either_way'), ioj: double, status: :in_progress,
      income: (double has_no_income_payments: nil, has_no_income_benefits: nil), income_payments: [double],
      outgoings_payments: [instance_double(Payment, payment_type: 'childcare')], income_benefits: [double], outgoings: (double has_no_other_outgoings: nil),
      documents: double, application_type: application_type, appeal_no_changes?: false,
      capital: (double has_premium_bonds: 'yes', has_no_properties: nil, has_no_savings: nil, has_no_investments: nil, has_national_savings_certificates: 'yes'),
      savings: [double], investments: [double], national_savings_certificates: [double], properties: [double]
    )
  end
  # rubocop:enable Layout/LineLength

  let(:datastore_application) do
    extra = {
      'means_details' => {
        'income_details' => {
          'income_payments' => [{
            'payment_type' => 'maintenance',
            'amount' => 10_000,
            'frequency' => 'week',
            'ownership_type' => 'applicant'
          }],
          'income_benefits' => [{
            'payment_type' => 'child',
            'amount' => 50_000,
            'frequency' => 'month',
            'ownership_type' => 'applicant'
          }],
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
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            Dependants
            IncomePaymentsDetails
            IncomeBenefitsDetails
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
            OtherCapitalDetails
            SupportingEvidence
            MoreInformation
          ]
        end

        it { is_expected.to match_array(expected_sections) }

        context 'when it is an appeal with no changes in financial circumstances' do
          let(:database_application) do
            instance_double(
              CrimeApplication, applicant: double, kase: (
                double case_type: 'appeal_to_crown_court',
                       appeal_financial_circumstances_changed: 'no'
              ),
              appeal_no_changes?: true,
              ioj: double, status: :in_progress,
              income: double, documents: double, application_type: application_type
            )
          end

          let(:expected_sections) do
            %w[
              Overview
              ClientDetails
              ContactDetails
              CaseDetails
              Offences
              Codefendants
              NextCourtHearing
              FirstCourtHearing
              JustificationForLegalAid
              PassportJustificationForLegalAid
              EmploymentDetails
              SupportingEvidence
              MoreInformation
            ]
          end

          it { is_expected.to match_array(expected_sections) }
        end
      end

      context 'for a "submitted" datastore application' do
        let(:crime_application) { datastore_application }

        let(:expected_sections) do
          %w[
            Overview
            ClientDetails
            ContactDetails
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            IncomePaymentsDetails
            IncomeBenefitsDetails
            Dependants
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
            OtherCapitalDetails
            SupportingEvidence
            MoreInformation
            LegalRepresentativeDetails
          ]
        end

        it { is_expected.to match_array(expected_sections) }

        context 'when it is an appeal with no changes in financial circumstances' do
          let(:datastore_application) do
            extra = {
              'means_details' => {
                'income_details' => {
                  'employment_status' => 'not_working',
                  'ended_employment_within_three_months' => 'no'
                }
              },
              'application_type' => application_type,
              'case_details' => {
                'case_type' => 'appeal_to_crown_court',
                'appeal_financial_circumstances_changed' => 'no'
              }
            }

            JSON.parse(LaaCrimeSchemas.fixture(1.0).read).deep_merge(extra)
          end

          let(:expected_sections) do
            %w[
              Overview
              ClientDetails
              ContactDetails
              CaseDetails
              Offences
              Codefendants
              NextCourtHearing
              FirstCourtHearing
              JustificationForLegalAid
              PassportJustificationForLegalAid
              EmploymentDetails
              SupportingEvidence
              MoreInformation
              LegalRepresentativeDetails
            ]
          end

          it { is_expected.to match_array(expected_sections) }
        end
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
      IncomePaymentsDetails
      IncomeBenefitsDetails
      Dependants
      OtherIncomeDetails
    ]

    context 'when an initial application' do
      let(:application_type) { 'initial' }

      it { is_expected.to match_array(expected_sections) }
    end
  end
end
