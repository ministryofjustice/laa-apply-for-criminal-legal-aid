require 'rails_helper'

RSpec.describe Steps::Client::HasPartnerForm do
  # Note: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  let(:arguments) { {
    crime_application: crime_application,
    client_has_partner: client_has_partner,
  } }

  let(:crime_application) { instance_double(CrimeApplication, client_has_partner: client_has_partner) }
  let(:client_has_partner) { nil }

  subject { described_class.new(arguments) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `client_has_partner` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:client_has_partner, :inclusion)).to eq(true)
      end
    end

    context 'when `client_has_partner` is not valid' do
      let(:client_has_partner) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:client_has_partner, :inclusion)).to eq(true)
      end
    end

    context 'when `client_has_partner` is valid' do
      let(:client_has_partner) { 'yes' }

      it 'saves the record' do
        expect(crime_application).to receive(:update).with(
          'client_has_partner' => YesNoAnswer::YES,
          status: ApplicationStatus::IN_PROGRESS,
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
