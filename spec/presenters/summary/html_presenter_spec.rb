require 'rails_helper'

# This spec is just a high level, smoke test of the sections.
# It is not intended to test conditionality or complex rules,
# as that is tested individually in each of the sections specs.
#
describe Summary::HtmlPresenter do
  subject(:presenter) { described_class.new(crime_application:) }

  let(:database_application) do
    instance_double(CrimeApplication, applicant: double, case: double, ioj: double,
                    status: :in_progress, income: double, outgoings: double,
                    documents: double, application_type: application_type,
                    capital: double, savings: [double], investments: [double])
  end

  let(:datastore_application) do
    extra = {
      'means_details' => {
        'capital_details' => {
          'savings' => [{ 'saving_type' => 'bank',
                          'provider_name' => 'Test Bank',
                          'account_holder' => 'applicant',
                          'sort_code' => '01-01-01',
                          'account_number' => '01234500',
                          'account_balance' => 10_001,
                          'is_overdrawn' => 'yes',
                          'are_wages_paid_into_account' => 'yes' }],
          'investments' => [{ 'investment_type' => 'share_isa',
                          'description' => 'About my ISA',
                          'value' => 10_001,
                          'holder' => 'applicant_and_partner' }],
          'has_premium_bonds' => 'yes',
          'premium_bonds_total_value' => 1234,
          'premium_bonds_holder_number' => '1234A'
        }
      },
      'application_type' => application_type,
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
            OtherIncomeDetails
            HousingPayments
            OtherOutgoingsDetails
            Savings
            PremiumBonds
            Investments
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
            CaseDetails
            Offences
            Codefendants
            NextCourtHearing
            FirstCourtHearing
            JustificationForLegalAid
            PassportJustificationForLegalAid
            EmploymentDetails
            IncomeDetails
            OtherIncomeDetails
            HousingPayments
            OtherOutgoingsDetails
            Savings
            PremiumBonds
            Investments
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
end
