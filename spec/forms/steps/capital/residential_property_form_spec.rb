require 'rails_helper'

RSpec.describe Steps::Capital::ResidentialPropertyForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }.merge(attributes)
  end

  let(:attributes) { {} }

  let(:crime_application) do
    instance_double(CrimeApplication, client_has_partner:, applicant:)
  end
  let(:applicant) { instance_double(Applicant, home_address?: home_address?) }
  let(:record) { Property.new }
  let(:client_has_partner) { 'no' }
  let(:home_address?) { true }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:house_type) }
    it { is_expected.to validate_presence_of(:bedrooms) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:outstanding_mortgage) }
    it { is_expected.to validate_presence_of(:percentage_applicant_owned) }
    it { is_expected.to validate_is_a(:has_other_owners, YesNoAnswer) }

    describe '#percentage_partner_owned' do
      before { allow(subject).to receive(:include_partner?).and_return(true) }

      it { is_expected.to validate_presence_of(:percentage_partner_owned) }
    end

    describe '#custom_house_type' do
      before { allow(subject).to receive(:house_type_is_listed?).and_return(false) }

      it { is_expected.to validate_presence_of(:custom_house_type) }
    end

    describe '#is_home_address' do
      context 'when applicant home address is present' do
        let(:home_address?) { true }

        it { is_expected.to validate_is_a(:is_home_address, YesNoAnswer) }
      end

      context 'when applicant home address is not present' do
        let(:home_address?) { false }

        it { is_expected.not_to validate_is_a(:is_home_address, YesNoAnswer) }
      end
    end
  end

  describe '#save' do
    let(:required_attributes) do
      {
        house_type: 'bungalow',
        custom_house_type: nil,
        bedrooms: 2,
        value: 170_000,
        outstanding_mortgage: 100_000,
        percentage_applicant_owned: 10,
        is_home_address: 'yes',
        has_other_owners: 'yes',
      }
    end

    context 'when house type is not listed' do
      context 'with valid attributes' do
        let(:attributes) { required_attributes.merge(house_type: 'custom', custom_house_type: 'custom house type') }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)
          expect(subject.save).to be(true)
        end
      end

      context 'with invalid attributes' do
        let(:attributes) { required_attributes.merge(house_type: 'custom') }

        it 'updates the record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end
      end
    end

    context 'when client has no partner' do
      let(:client_has_partner) { 'no' }

      context 'for valid details' do
        let(:attributes) { required_attributes }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)

          expect(subject.save).to be(true)
        end
      end
    end

    context 'when client has a partner' do
      let(:client_has_partner) { 'yes' }

      context 'for invalid details' do
        let(:attributes) { required_attributes }

        it 'updates the record' do
          expect(record).not_to receive(:update)

          expect(subject.save).to be(false)
        end
      end

      context 'for valid details' do
        let(:attributes) { required_attributes.merge(percentage_partner_owned: 10) }

        it 'updates the record' do
          expect(record).to receive(:update).and_return(true)

          expect(subject.save).to be(true)
        end
      end
    end
  end
end
