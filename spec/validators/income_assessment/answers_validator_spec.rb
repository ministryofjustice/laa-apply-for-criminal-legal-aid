require 'rails_helper'

RSpec.describe IncomeAssessment::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(Income, crime_application:, errors:) }
  let(:crime_application) { instance_double CrimeApplication }

  let(:errors) { double(:errors) }
  let(:requires_means_assessment?) { true }

  before do
    allow(crime_application).to receive_messages(
      income: record,
      kase: double(case_type: 'summary_only')
    )

    allow(validator).to receive_messages(
      evidence_of_passporting_means_forthcoming?: false,
      requires_means_assessment?: requires_means_assessment?
    )
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when means assessment not required' do
      let(:requires_means_assessment?) { false }

      it { is_expected.to be(false) }
    end

    context 'when means assessment required' do
      let(:requires_means_assessment?) { true }

      it { is_expected.to be(true) }
    end
  end

  describe '#validate' do
    before { allow(record).to receive_messages(**attributes) }

    context 'when all validations pass' do
      let(:errors) { [] }

      let(:attributes) do
        {
          employment_status: ['not_working'],
          income_above_threshold: 'no',
          has_frozen_income_or_assets: 'no',
          has_no_income_payments: 'no',
          has_no_income_benefits: 'no',
          income_payments: [instance_double(Payment, complete?: true)],
          income_benefits: [instance_double(Payment, complete?: true)],
          client_has_dependants: 'yes',
          manage_without_income: 'Use savings',
        }
      end

      it 'does not add any errors' do
        subject.validate
      end
    end

    context 'when validation fails' do
      let(:errors) { double(:errors) }

      let(:attributes) do
        {
          employment_status: nil,
          income_above_threshold: nil,
          has_frozen_income_or_assets: nil,
          has_no_income_payments: 'no',
          has_no_income_benefits: 'no',
          income_payments: [],
          income_benefits: [],
          client_has_dependants: nil,
          manage_without_income: nil
        }
      end

      it 'adds errors for all failed validations' do
        expect(errors).to receive(:add).with(:employment_status, :incomplete)
        expect(errors).to receive(:add).with(:income_before_tax, :incomplete)
        expect(errors).to receive(:add).with(:income_payments, :incomplete)
        expect(errors).to receive(:add).with(:income_benefits, :incomplete)
        expect(errors).to receive(:add).with(:dependants, :incomplete)
        expect(errors).to receive(:add).with(:manage_without_income, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end
    end
  end

  describe '#employment_status_complete?' do
    context 'when employment_status is present' do
      before { allow(record).to receive(:employment_status).and_return('not_working') }

      it 'returns true' do
        expect(subject.employment_status_complete?).to be(true)
      end
    end

    context 'when employment_status is empty' do
      before { allow(record).to receive(:employment_status).and_return([]) }

      it 'returns false' do
        expect(subject.employment_status_complete?).to be(false)
      end
    end
  end

  describe '#income_before_tax_complete?' do
    context 'when income_above_threshold is "yes"' do
      before { allow(record).to receive(:income_above_threshold).and_return('yes') }

      it 'returns true' do
        expect(subject.income_before_tax_complete?).to be(true)
      end
    end

    context 'when income_above_threshold is "no"' do
      before { allow(record).to receive(:income_above_threshold).and_return('no') }

      it 'returns true' do
        expect(subject.income_before_tax_complete?).to be(true)
      end
    end

    context 'when income_above_threshold is nil' do
      before { allow(record).to receive(:income_above_threshold).and_return(nil) }

      it 'returns false' do
        expect(subject.income_before_tax_complete?).to be(false)
      end
    end
  end

  describe '#frozen_income_savings_assets_complete?' do
    context 'when income_below_threshold? is true and has_frozen_income_or_assets is present' do
      before do
        allow(subject).to receive(:income_below_threshold?).and_return(true)
        allow(record).to receive(:has_frozen_income_or_assets).and_return('yes')
      end

      it 'returns true' do
        expect(subject.frozen_income_savings_assets_complete?).to be(true)
      end
    end

    context 'when income_below_threshold? is true but has_frozen_income_or_assets is nil' do
      before do
        allow(subject).to receive(:income_below_threshold?).and_return(true)
        allow(record).to receive(:has_frozen_income_or_assets).and_return(nil)
      end

      it 'returns false' do
        expect(subject.frozen_income_savings_assets_complete?).to be(false)
      end
    end

    context 'when income_below_threshold? is false' do
      before { allow(subject).to receive(:income_below_threshold?).and_return(false) }

      it 'returns true' do
        expect(subject.frozen_income_savings_assets_complete?).to be(true)
      end
    end
  end

  describe '#income_payments_complete?' do
    context 'when has_no_income_payments is yes' do
      before { allow(record).to receive(:has_no_income_payments).and_return('yes') }

      it 'returns true' do
        expect(subject.income_payments_complete?).to be(true)
      end
    end

    context 'when has_no_income_payments is no and income_payments are present and complete' do
      before do
        allow(record).to receive(:has_no_income_payments).and_return('no')

        allow(record).to receive(:income_payments) {
          [instance_double(Payment, complete?: true)]
        }
      end

      it 'returns true' do
        expect(subject.income_payments_complete?).to be(true)
      end
    end

    context 'when has_no_income_payments is no and income_payments are present but not complete' do
      before do
        allow(record).to receive(:has_no_income_payments).and_return('no')

        allow(record).to receive(:income_payments) {
          [instance_double(Payment, complete?: false)]
        }
      end

      it 'returns false' do
        expect(subject.income_payments_complete?).to be(false)
      end
    end

    context 'when has_no_income_payments is no and income_payments are empty' do
      before do
        allow(record).to receive_messages(has_no_income_payments: 'no', income_payments: [])
      end

      it 'returns false' do
        expect(subject.income_payments_complete?).to be(false)
      end
    end
  end

  describe '#income_benefits_complete?' do
    context 'when has_no_income_benefits is yes' do
      before { allow(record).to receive(:has_no_income_benefits).and_return('yes') }

      it 'returns true' do
        expect(subject.income_benefits_complete?).to be(true)
      end
    end

    context 'when has_no_income_benefits is no and income_benefits are present and complete' do
      before do
        allow(record).to receive_messages(has_no_income_benefits: 'no',
                                          income_benefits: [double('Benefit', complete?: true)])
      end

      it 'returns true' do
        expect(subject.income_benefits_complete?).to be(true)
      end
    end

    context 'when has_no_income_benefits is no and income_benefits are present but not complete' do
      before do
        allow(record).to receive_messages(has_no_income_benefits: 'no',
                                          income_benefits: [double('Benefit', complete?: false)])
      end

      it 'returns false' do
        expect(subject.income_benefits_complete?).to be(false)
      end
    end

    context 'when has_no_income_benefits is no and income_benefits are empty' do
      before do
        allow(record).to receive_messages(has_no_income_benefits: 'no', income_benefits: [])
      end

      it 'returns false' do
        expect(subject.income_benefits_complete?).to be(false)
      end
    end
  end

  describe '#dependants_complete?' do
    context 'when requires_full_means_assessment? is false' do
      before { allow(subject).to receive(:requires_full_means_assessment?).and_return(false) }

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end

    context 'when requires_full_means_assessment? is true and client_has_dependants is NO' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive(:client_has_dependants).and_return(YesNoAnswer::NO.to_s)
      end

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end

    context 'when requires_full_means_assessment and client_has_dependants but dependants are not present' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive_messages(client_has_dependants: YesNoAnswer::YES.to_s, dependants: [])
      end

      it 'returns false' do
        expect(subject.dependants_complete?).to be(false)
      end
    end

    context 'when requires_full_means_assessment and client_has_dependants but dependants are present' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive_messages(client_has_dependants: YesNoAnswer::YES.to_s,
                                          dependants: [double('Dependant')])
      end

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end
  end

  describe '#manage_without_income_complete?' do
    context 'when both income_payments and income_benefits are empty' do
      before do
        allow(record).to receive_messages(income_payments: [], income_benefits: [])
      end

      it 'returns true if manage_without_income is present' do
        allow(record).to receive(:manage_without_income).and_return(true)
        expect(subject.manage_without_income_complete?).to be(true)
      end

      it 'returns false if manage_without_income is not present' do
        allow(record).to receive(:manage_without_income).and_return(nil)
        expect(subject.manage_without_income_complete?).to be(false)
      end
    end
  end
end
