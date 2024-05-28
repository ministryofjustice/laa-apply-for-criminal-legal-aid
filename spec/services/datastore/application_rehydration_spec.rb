require 'rails_helper'

RSpec.describe Datastore::ApplicationRehydration do
  subject { described_class.new(crime_application, parent:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant:,
      partner:,
    )
  end

  let(:applicant) { nil }
  let(:partner) { nil }
  let(:parent) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read) }
  let(:means_passport) { [] }

  before do
    allow(crime_application).to receive(:update!).and_return(true)
  end

  describe '#call' do
    let(:parent_ioj) { Ioj.new(types: ['foobar']) }

    before do
      allow(subject.parent).to receive_messages(ioj: parent_ioj, means_passport: means_passport)
    end

    it 're-hydrates the new application using the parent details' do # rubocop:disable RSpec/ExampleLength
      expect(
        crime_application
      ).to receive(:update!).with(
        client_has_partner: YesNoAnswer::NO,
        parent_id: '47a93336-7da6-48ec-b139-808ddd555a41',
        is_means_tested: an_instance_of(YesNoAnswer),
        date_stamp: an_instance_of(DateTime),
        ioj_passport: an_instance_of(Array),
        means_passport: an_instance_of(Array),
        applicant: an_instance_of(Applicant),
        partner: an_instance_of(Partner),
        partner_detail: an_instance_of(PartnerDetail),
        case: an_instance_of(Case),
        income: an_instance_of(Income),
        documents: all(be_a(Document)),
        dependants: all(be_a(Dependant)),
        outgoings: an_instance_of(Outgoings),
        outgoings_payments: all(be_a(OutgoingsPayment)),
        additional_information: parent['additional_information'],
        income_payments: all(be_a(IncomePayment)),
        income_benefits: all(be_a(IncomeBenefit)),
        capital: nil,
        savings: [], # capital and savings tested separately
        investments: [], # capital and investments tested separately
        national_savings_certificates: [], # capital and certificates tested separately
        properties: [],
        evidence_last_run_at: an_instance_of(DateTime),
        evidence_prompts: an_instance_of(Array),
      )

      expect(
        Ioj
      ).to receive(:new).with(
        hash_including('types' => ['foobar'])
      ).and_call_original

      expect(
        Income
      ).to receive(:new).with(
        hash_including(
          'lost_job_in_custody' => 'yes',
          'date_job_lost' => '2023-09-01'.to_date,
        )
      ).and_call_original

      expect(subject.call).to be(true)
    end

    context 'for a split case passported application' do
      let(:parent) { super().deep_merge('return_details' => { 'reason' => 'split_case' }) }
      let(:parent_ioj) { nil }

      it 'sets the `passport_override` flag on the Ioj record' do
        expect(
          Ioj
        ).to receive(:new).with(
          passport_override: true
        )

        expect(subject.call).to be(true)
      end
    end

    context 'date stamp' do
      let(:parent) do
        super().deep_merge('case_details' => { 'case_type' => case_type })
      end

      context 'for a parent that is non means tested' do
        let(:case_type) { nil }
        let(:means_passport) { ['on_not_means_tested'] }

        it 'inherits the existing date stamp' do
          expect(
            crime_application
          ).to receive(:update!).with(
            hash_including(
              date_stamp: an_instance_of(DateTime)
            )
          )

          subject.call
        end
      end

      context 'for a parent with a date-stampable case type' do
        let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

        it 'inherits the existing date stamp' do
          expect(
            crime_application
          ).to receive(:update!).with(
            hash_including(
              date_stamp: an_instance_of(DateTime)
            )
          )

          subject.call
        end
      end

      context 'for a parent with a non date-stampable case type' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        it 'leaves the date stamp `nil`' do
          expect(
            crime_application
          ).to receive(:update!).with(
            hash_including(
              date_stamp: nil
            )
          )

          subject.call
        end
      end
    end

    context 'when means_details contains dependants' do
      let(:dependants) do
        {
          'dependants' => [{ 'age' => 0 }, { 'age' => 17 }],
          'client_has_dependants' => 'yes'
        }
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'income_details' => dependants })
      end

      it 'sets `income.client_has_dependants` field' do
        expect(Income).to receive(:new).with(
          hash_including(
            'client_has_dependants' => 'yes',
          )
        ).and_call_original

        subject.call
      end

      it 'generates dependants' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            dependants: contain_exactly(Dependant, Dependant)
          )
        )

        subject.call
      end
    end

    context 'when means_details contains income_payments' do
      let(:income_payments) do
        {
          'income_payments' => [
            {
              'payment_type' => 'other',
              'amount' => 1289,
              'frequency' => 'fortnight',
              'ownership_type' => 'applicant',
              'metadata' => { 'details' => "A note\n2022" },
            },
          ]
        }
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'income_details' => income_payments })
      end

      it 'generates income payments' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            income_payments: contain_exactly(IncomePayment)
          )
        )

        subject.call
      end

      it 'forces IncomePayment to be constructed using pence value' do
        expect(
          IncomePayment
        ).to receive(:new).with(
          payment_type: 'other',
          amount: 1289,
          frequency: 'fortnight',
          ownership_type: 'applicant',
          metadata: { details: "A note\n2022" },
        )

        subject.call
      end
    end

    context 'when means_details contains income_benefits' do
      let(:income_benefits) do
        {
          'income_benefits' => [
            {
              'payment_type' => 'other',
              'amount' => 1289,
              'frequency' => 'fortnight',
              'ownership_type' => 'applicant',
              'metadata' => { 'details' => "A note\n2022" },
            },
            {
              'payment_type' => 'child',
              'amount' => 89_101,
              'frequency' => 'annual',
              'ownership_type' => 'applicant'
            },
          ]
        }
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'income_details' => income_benefits })
      end

      it 'generates income benefits' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            income_benefits: contain_exactly(IncomeBenefit, IncomeBenefit)
          )
        )

        subject.call
      end

      it 'forces IncomeBenefit to be constructed using pence value' do
        expect(
          IncomeBenefit
        ).to receive(:new).with(
          payment_type: 'other',
          amount: 1289,
          frequency: 'fortnight',
          ownership_type: 'applicant',
          metadata: { details: "A note\n2022" },
        )

        expect(
          IncomeBenefit
        ).to receive(:new).with(
          payment_type: 'child',
          amount: 89_101,
          frequency: 'annual',
          ownership_type: 'applicant',
        )

        subject.call
      end
    end

    context 'when means_details contains outgoings' do
      let(:outgoings) do
        {
          'outgoings' => [
            {
              'payment_type' => 'legal_aid_contribution',
              'amount' => 12_344,
              'frequency' => 'annual',
              'ownership_type' => 'applicant_and_partner',
              'metadata' => { 'case_reference' => "CASE101\n2023-12-02" },
            },
            {
              'payment_type' => 'rent',
              'amount' => 56_432,
              'frequency' => 'month',
              'ownership_type' => 'applicant_and_partner',
            },
          ]
        }
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'outgoings_details' => outgoings })
      end

      it 'generates outgoings payments' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            outgoings_payments: contain_exactly(OutgoingsPayment, OutgoingsPayment)
          )
        )

        subject.call
      end

      it 'forces OutgoingsPayment to be constructed using pence value' do
        expect(
          OutgoingsPayment
        ).to receive(:new).with(
          payment_type: 'legal_aid_contribution',
          amount: 12_344,
          frequency: 'annual',
          ownership_type: 'applicant_and_partner',
          metadata: { case_reference: "CASE101\n2023-12-02" },
        )

        expect(
          OutgoingsPayment
        ).to receive(:new).with(
          payment_type: 'rent',
          amount: 56_432,
          frequency: 'month',
          ownership_type: 'applicant_and_partner'
        )

        subject.call
      end
    end

    context 'when means_details contains income_details' do
      let(:income_details) do
        {
          'income_payments' => [{ 'payment_type' => 'maintenance',
                                  'amount' => 20_000,
                                  'frequency' => 'week',
                                  'ownership_type' => 'applicant' },
                                { 'payment_type' => 'rent',
                                  'amount' => 60_000,
                                  'frequency' => 'month',
                                  'ownership_type' => 'applicant' }],
          'income_benefits' => [{ 'payment_type' => 'child',
                                  'amount' => 10_000,
                                  'frequency' => 'month',
                                  'ownership_type' => 'applicant' },
                                { 'payment_type' => 'incapacity',
                                  'amount' => 5_000,
                                  'frequency' => 'month',
                                  'ownership_type' => 'applicant' }],
          'employment_status' => ['not_working'],
          'ended_employment_within_three_months' => 'yes',
          'lost_job_in_custody' => 'yes',
          'date_job_lost' => Date.new(2023, 9, 1),
          'income_above_threshold' => 'no',
          'has_frozen_income_or_assets' => 'no',
          'client_owns_property' => 'no',
          'has_savings' => 'no',
          'manage_without_income' => 'other',
          'manage_other_details' => 'Another way they manage'
        }
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'income_details' => income_details })
      end

      it 'generates income_payments' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            income_payments: contain_exactly(IncomePayment, IncomePayment)
          )
        )

        subject.call
      end

      it 'generates income_benefits' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            income_benefits: contain_exactly(IncomeBenefit, IncomeBenefit)
          )
        )

        subject.call
      end
    end

    context 'when means_details contains capital_details' do
      let(:capital_details) do
        {
          'savings' => [{ 'saving_type' => 'bank',
                          'provider_name' => 'Test Bank',
                          'ownership_type' => 'applicant',
                          'sort_code' => '01-01-01',
                          'account_number' => '01234500',
                          'account_balance' => 10_001,
                          'is_overdrawn' => 'yes',
                          'are_wages_paid_into_account' => 'yes' },
                        { 'saving_type' => 'building_society',
                          'provider_name' => 'Test Building Society',
                          'ownership_type' => 'applicant',
                          'sort_code' => '12-34-56',
                          'account_number' => '01234500',
                          'account_balance' => 200_050,
                          'is_overdrawn' => 'no',
                          'are_wages_paid_into_account' => 'no' }],
          'properties' => [{ 'property_type' => 'residential',
                             'house_type' => 'other',
                             'other_house_type' => 'other house type',
                             'size_in_acres' => nil,
                             'usage' => nil,
                             'bedrooms' => 92,
                             'value' => 200_000,
                             'outstanding_mortgage' => 100_000,
                             'percentage_applicant_owned' => 90.01,
                             'percentage_partner_owned' => 10.01,
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
      end

      let(:parent) do
        super().deep_merge('means_details' => { 'capital_details' => capital_details })
      end

      it 'generates savings' do
        expect(crime_application).to receive(:update!).with(
          hash_including(
            savings: contain_exactly(Saving, Saving),
            properties: contain_exactly(Property)
          )
        )

        subject.call
      end
    end

    context 'for an already re-hydrated application' do
      let(:applicant) { 'something' }

      it 'skips the re-hydration, to avoid overwriting any details' do
        expect(crime_application).not_to receive(:update!)
        expect(subject.call).to be_nil
      end
    end
  end
end
