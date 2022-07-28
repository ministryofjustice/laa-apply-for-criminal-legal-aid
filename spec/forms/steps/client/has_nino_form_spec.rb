require 'rails_helper'

RSpec.describe Steps::Client::HasNinoForm do
  # Note: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  let(:arguments) { {
    crime_application: crime_application,
    has_nino: has_nino,
    nino: nino
  } }

  let(:crime_application) { 
    instance_double(CrimeApplication, 
      applicant_details: applicant_details
    )
  }

  let(:applicant_details) {instance_double(ApplicantDetails, :update)}
  let(:has_nino) { nil }
  let(:nino) { nil }

  subject { described_class.new(arguments) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_nino` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to eq(true)
      end
    end

    context 'when `has_nino` is not valid' do
      let(:has_nino) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:has_nino, :inclusion)).to eq(true)
      end
    end

    context 'when `has_nino` is valid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'AB123456C' }

      it 'saves the record' do
        expect(crime_application.applicant_details).to receive(:update).with(
          'has_nino' => YesNoAnswer::YES,
          'nino' => 'AB123456C'
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when `nino` is blank' do
      let(:has_nino) { 'yes' }
      let(:nino) { '' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:nino, :invalid)).to eq(true)
      end
    end

    context 'when `nino` is invalid' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'not a NINO' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:nino, :invalid)).to eq(true)
      end
    end

    context 'when validations pass' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'AB123456C' }
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant_details,
                      expected_attributes: {
                        'has_nino' => YesNoAnswer::YES,
                        'nino' => "AB123456C"
                      }
    end
  end
end
