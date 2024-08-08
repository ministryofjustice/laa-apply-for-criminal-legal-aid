require 'rails_helper'

RSpec.describe Steps::Client::HasPartnerForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_partner:,
    }
  end

  let(:crime_application) do
    CrimeApplication.new(
      partner_detail:,
      partner:,
      income:,
    )
  end

  let(:has_partner) { nil }
  let(:partner_detail) { PartnerDetail.new }
  let(:partner) { Partner.new }
  let(:income) { Income.new }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_partner` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_partner, :inclusion)).to be(true)
      end
    end

    context 'when `has_partner` is not valid' do
      let(:has_partner) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject.has_partner.to_s).to eq 'maybe'
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_partner, :inclusion)).to be(true)
      end
    end

    context 'when `has_partner` is `yes`' do
      let(:has_partner) { 'yes' }
      let(:partner_detail) do
        PartnerDetail.new(
          relationship_status: 'widowed',
          separation_date: '2023-01-01',
        )
      end

      it 'saves the record and resets client relationship status' do
        expect(partner_detail).to receive(:update!).with(
          {
            relationship_status: nil,
            separation_date: nil,
            has_partner: 'yes'
          }
        ).and_return(true)

        expect(partner).not_to receive(:destroy!)
        expect(subject.save).to be(true)
      end
    end

    context 'when `has_partner` is `no`' do
      let(:has_partner) { 'no' }
      let(:income) do
        Income.new(partner_employment_status: ['not_working'])
      end

      before do
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'applicant',
          amount: 1,
          frequency: 'week',
          payment_type: 'maintainance',
        )

        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'partner',
          amount: 1,
          frequency: 'week',
          payment_type: 'maintainance',
        )

        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'partner',
          amount: 1,
          frequency: 'week',
          payment_type: 'jsa',
        )

        crime_application.save!
      end

      it 'saves the record and deletes partner information' do
        expect(crime_application.payments.size).to eq 3
        expect(income).to receive(:update!).with({ partner_employment_status: [] })
        expect(partner).to receive(:destroy!)
        expect(partner_detail).to receive(:destroy!)

        expect(subject.save).to be(true)
        expect(crime_application.payments.for_client.size).to eq 1
      end
    end
  end
end
