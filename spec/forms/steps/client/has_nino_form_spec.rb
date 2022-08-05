require 'rails_helper'

RSpec.describe Steps::Client::HasNinoForm do
  # Note: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  let(:arguments) { {
    crime_application: crime_application,
    nino: nino
  } }

  let(:crime_application) { 
    instance_double(CrimeApplication)
  }

  let(:nino) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when `nino` is blank' do
      let(:nino) { '' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:nino, :invalid)).to eq(true)
      end
    end

    context 'when `nino` is invalid' do
      context 'with a random string' do
        let(:nino) { 'not a NINO' }

        it 'has a validation error on the field' do
          expect(subject).to_not be_valid
          expect(subject.errors.of_kind?(:nino, :invalid)).to eq(true)
        end
      end

      context 'with an unused prefix' do
        let(:nino) { 'BG123456C' }

        it 'has a validation error on the field' do
          expect(subject).to_not be_valid
          expect(subject.errors.of_kind?(:nino, :invalid)).to eq(true)
        end
      end
    end

    context 'when `nino` is valid' do
      context 'with spaces between numbers' do
        let(:nino) { 'AB 12 34 56 C' }
        it 'passes validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:nino, :invalid)).to eq(false)
        end
      end
      context 'with trailing spaces' do
        let(:nino) { ' AB 1234 56C ' }
        it 'passed validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:nino, :invalid)).to eq(false)
        end
      end
    end

    context 'when validations pass' do
      let(:nino) { 'AB123456C' }
      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'nino' => "AB123456C"
                      }
    end
  end
end
