require 'rails_helper'

RSpec.describe OutgoingsAssessment::AnswersValidator, type: :model do
  # rubocop:disable RSpec/MessageChain
  #
  subject(:validator) { described_class.new(record:, crime_application:) }

  let(:record) { instance_double(Outgoings, crime_application:, errors:) }
  let(:crime_application) { instance_double CrimeApplication }

  let(:errors) { [] }
  let(:requires_full_means_assessment?) { true }
  let(:involvement_in_case?) { nil }

  before do
    allow(crime_application).to receive_messages(outgoings: record)

    allow(validator).to receive_messages(
      requires_full_means_assessment?: requires_full_means_assessment?
    )

    allow(crime_application).to receive(:partner_detail).and_return(
      instance_double(PartnerDetail)
    )

    allow(crime_application).to receive_message_chain(:partner_detail, :involvement_in_case) {
      involvement_in_case?
    }
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when full means assessment not required' do
      let(:requires_full_means_assessment?) { false }

      it { is_expected.to be(false) }
    end

    context 'when full means assessment required' do
      let(:requires_full_means_assessment?) { true }

      it { is_expected.to be(true) }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    before do
      expect(validator).to receive(:validate)
      expect(errors).to receive(:empty?) { !errors_added? }
    end

    context 'when validate does not add errors' do
      let(:errors_added?) { false }

      it { is_expected.to be(true) }
    end

    context 'when validate adds errors' do
      let(:errors_added?) { true }

      it { is_expected.to be(false) }
    end
  end

  describe '#validate' do
    context 'when all validations pass' do
      let(:errors) { [] }

      let(:involvement_in_case?) { 'none' }

      before do
        allow(record).to receive_message_chain(:outgoings_payments, :rent) {
          instance_double(Payment, complete?: true)
        }

        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) {
          instance_double(Payment, complete?: true)
        }

        allow(record).to receive_messages(
          housing_payment_type: 'rent',
          pays_council_tax: 'no',
          has_no_other_outgoings: nil,
          other_payments: [instance_double(Payment, complete?: true)],
          income_tax_rate_above_threshold: true,
          partner_income_tax_rate_above_threshold: true,
          outgoings_more_than_income: 'yes',
          how_manage: 'budgeting'
        )
      end

      it 'does not add any errors' do
        subject.validate
      end

      context 'when partner is codefendant with no conflict' do
        let(:involvement_in_case?) { 'codefendant' }

        before do
          allow(crime_application).to receive_message_chain(:partner_detail, :conflict_of_interest) {
            'no'
          }
        end

        it 'does not add any errors' do
          subject.validate
        end
      end
    end

    context 'when validations fail' do
      let(:errors) { double(:errors) }
      let(:involvement_in_case?) { 'none' }

      before do
        allow(record).to receive_message_chain(:outgoings_payments, :rent) {
          instance_double(Payment, complete?: false)
        }

        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) {
          instance_double(Payment, complete?: false)
        }

        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) {
          instance_double(Payment, complete?: false)
        }

        allow(record).to receive_messages(
          housing_payment_type: 'rent',
          pays_council_tax: nil,
          other_payments: [],
          has_no_other_outgoings: nil,
          income_tax_rate_above_threshold: false,
          partner_income_tax_rate_above_threshold: false,
          outgoings_more_than_income: nil
        )
      end

      it 'adds errors for all failed validations' do
        expect(errors).to receive(:add).with(:rent, :incomplete)
        expect(errors).to receive(:add).with(:council_tax, :incomplete)
        expect(errors).to receive(:add).with(:outgoings_payments, :incomplete)
        expect(errors).to receive(:add).with(:income_tax_rate, :incomplete)
        expect(errors).to receive(:add).with(:partner_income_tax_rate, :incomplete)
        expect(errors).to receive(:add).with(:outgoings_more_than, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end
    end
  end

  describe '#housing_payment_type_complete?' do
    it 'returns true when housing_payment_type is present' do
      allow(record).to receive(:housing_payment_type).and_return('mortgage')
      expect(subject.housing_payment_type_complete?).to be(true)
    end

    it 'returns false when housing_payment_type is nil' do
      allow(record).to receive(:housing_payment_type).and_return(nil)
      expect(subject.housing_payment_type_complete?).to be(false)
    end
  end

  describe '#mortgage_complete?' do
    context "when housing_payment_type is 'mortgage'" do
      before do
        allow(record).to receive(:housing_payment_type).and_return('mortgage')
      end

      it 'returns true if mortgage is complete' do
        allow(record).to receive_message_chain(:outgoings_payments, :mortgage) {
          instance_double(Payment, complete?: true)
        }
        expect(subject.mortgage_complete?).to be(true)
      end

      it 'returns false if mortgage is incomplete' do
        allow(record).to receive_message_chain(:outgoings_payments, :mortgage) {
          instance_double(Payment, complete?: false)
        }

        expect(subject.mortgage_complete?).to be(false)
      end

      it 'returns false if mortgage not present' do
        allow(record).to receive_message_chain(:outgoings_payments, :mortgage) { nil }

        expect(subject.mortgage_complete?).to be(false)
      end
    end

    context "when housing_payment_type is not 'mortgage'" do
      it 'returns true' do
        allow(record).to receive(:housing_payment_type).and_return('rent')
        expect(subject.mortgage_complete?).to be(true)
      end
    end
  end

  describe '#rent_complete?' do
    context "when housing_payment_type is 'rent'" do
      before do
        allow(record).to receive(:housing_payment_type).and_return('rent')
      end

      it 'returns true if rent is complete' do
        allow(record).to receive_message_chain(:outgoings_payments, :rent) {
          instance_double(Payment, complete?: true)
        }
        expect(subject.rent_complete?).to be(true)
      end

      it 'returns false if rent is incomplete' do
        allow(record).to receive_message_chain(:outgoings_payments, :rent) {
          instance_double(Payment, complete?: false)
        }
        expect(subject.rent_complete?).to be(false)
      end

      it 'returns false if rent not present' do
        allow(record).to receive_message_chain(:outgoings_payments, :rent) { nil }

        expect(subject.rent_complete?).to be(false)
      end
    end

    context "when housing_payment_type is not 'rent'" do
      it 'returns true' do
        allow(record).to receive(:housing_payment_type).and_return('mortgage')
        expect(subject.rent_complete?).to be(true)
      end
    end
  end

  describe '#board_and_lodging_complete?' do
    context "when housing_payment_type is 'board_and_lodging'" do
      before do
        allow(record).to receive(:housing_payment_type).and_return('board_and_lodging')
      end

      it 'returns true if board_and_lodging is complete' do
        allow(record).to receive_message_chain(:outgoings_payments, :board_and_lodging) {
          instance_double(Payment, complete?: true)
        }
        expect(subject.board_and_lodging_complete?).to be(true)
      end

      it 'returns false if board_and_lodging is incomplete' do
        allow(record).to receive_message_chain(:outgoings_payments, :board_and_lodging) {
          instance_double(Payment, complete?: false)
        }
        expect(subject.board_and_lodging_complete?).to be(false)
      end

      it 'returns false if board_and_lodging not present' do
        allow(record).to receive_message_chain(:outgoings_payments, :board_and_lodging) { nil }

        expect(subject.board_and_lodging_complete?).to be(false)
      end
    end

    context "when housing_payment_type is not 'board_and_lodging'" do
      it 'returns true' do
        allow(record).to receive(:housing_payment_type).and_return('mortgage')
        expect(subject.board_and_lodging_complete?).to be(true)
      end
    end
  end

  describe '#council_tax_complete?' do
    context "when housing_payment_type is one that pays 'council_tax'" do
      before do
        allow(record).to receive(:housing_payment_type).and_return('mortgage')
      end

      it "returns true if pays_council_tax 'no'" do
        allow(record).to receive(:pays_council_tax).and_return('no')

        expect(subject.council_tax_complete?).to be(true)
      end

      it 'returns true if council_tax is complete' do
        allow(record).to receive(:pays_council_tax).and_return('yes')

        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) {
          instance_double(Payment, complete?: true)
        }

        expect(subject.council_tax_complete?).to be(true)
      end

      it 'returns false if council_tax is incomplete' do
        allow(record).to receive(:pays_council_tax).and_return('yes')

        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) {
          instance_double(Payment, complete?: false)
        }

        expect(subject.council_tax_complete?).to be(false)
      end

      it 'returns false if council_tax not present' do
        allow(record).to receive(:pays_council_tax).and_return('yes')
        allow(record).to receive_message_chain(:outgoings_payments, :council_tax) { nil }

        expect(subject.council_tax_complete?).to be(false)
      end
    end

    context "when housing_payment_type is one that does not pay 'council_tax'" do
      it 'returns true' do
        allow(record).to receive(:housing_payment_type).and_return('none')
        expect(subject.council_tax_complete?).to be(true)
      end
    end
  end

  describe '#income_tax_rate_complete?' do
    context 'when income_tax_rate_above_threshold is present' do
      before do
        allow(record).to receive(:income_tax_rate_above_threshold).and_return(true)
      end

      it 'returns true' do
        expect(subject.income_tax_rate_complete?).to be(true)
      end
    end

    context 'when income_tax_rate_above_threshold is nil' do
      before do
        allow(record).to receive(:income_tax_rate_above_threshold).and_return(nil)
      end

      it 'returns false' do
        expect(subject.income_tax_rate_complete?).to be(false)
      end
    end
  end

  describe '#partner_income_tax_rate_complete?' do
    let(:involvement_in_case?) { 'none' }

    context 'when partner_income_tax_rate_above_threshold is present' do
      before do
        allow(record).to receive(:partner_income_tax_rate_above_threshold).and_return(true)
      end

      it 'returns true' do
        expect(subject.partner_income_tax_rate_complete?).to be(true)
      end
    end

    context 'when partner_income_tax_rate_above_threshold is nil' do
      before do
        allow(record).to receive(:partner_income_tax_rate_above_threshold).and_return(nil)
      end

      it 'returns false' do
        expect(subject.partner_income_tax_rate_complete?).to be(false)
      end
    end
  end

  describe '#outgoings_more_than_income_complete?' do
    context "when outgoings_more_than_income is 'yes' and how_manage is present" do
      before do
        allow(record).to receive_messages(outgoings_more_than_income: 'yes', how_manage: 'Description')
      end

      it 'returns true' do
        expect(subject.outgoings_more_than_income_complete?).to be(true)
      end
    end

    context "when outgoings_more_than_income is 'no'" do
      before do
        allow(record).to receive(:outgoings_more_than_income).and_return('no')
      end

      it 'returns true' do
        expect(subject.outgoings_more_than_income_complete?).to be(true)
      end
    end

    context 'when outgoings_more_than_income is nil' do
      before do
        allow(record).to receive(:outgoings_more_than_income).and_return(nil)
      end

      it 'returns false' do
        expect(subject.outgoings_more_than_income_complete?).to be(false)
      end
    end
  end

  # rubocop:enable RSpec/MessageChain
end
