require 'rails_helper'

RSpec.describe Steps::Client::HasNinoForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: applicant_record,
    }.merge(
      form_attributes
    )
  end

  let(:form_attributes) do
    { nino: }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }

  describe '#save' do
    context 'validations' do
      context 'when `nino` is blank' do
        let(:nino) { '' }

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
        end
      end

      context 'when `nino` is invalid' do
        context 'with a random string' do
          let(:nino) { 'not a NINO' }

          it 'has a validation error on the field' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
          end
        end

        context 'with an unused prefix' do
          let(:nino) { 'BG123456C' }

          it 'has a validation error on the field' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:nino, :invalid)).to be(true)
          end
        end
      end

      context 'when `nino` is valid' do
        context 'with spaces between numbers' do
          let(:nino) { 'AB 12 34 56 C' }

          it 'passes validation' do
            expect(subject).to be_valid
            expect(subject.errors.of_kind?(:nino, :invalid)).to be(false)
          end

          it 'removes spaces from input' do
            expect(subject.nino).to eq('AB123456C')
          end
        end

        context 'with trailing spaces' do
          let(:nino) { ' AB 1234 56C ' }

          it 'passed validation' do
            expect(subject).to be_valid
            expect(subject.errors.of_kind?(:nino, :invalid)).to be(false)
          end
        end
      end
    end

    context 'when validations pass' do
      let(:applicant_record) { Applicant.new(form_attributes) }
      let(:nino) { 'AB123456C' }

      context 'when NINO has changed' do
        let(:form_attributes) { super().merge(nino: 'NC123456A') }

        it_behaves_like 'a has-one-association form',
                        association_name: :applicant,
                        expected_attributes: {
                          'nino' => 'NC123456A',
                          :passporting_benefit => nil,
                        }
      end

      context 'when NINO is the same as in the persisted record' do
        it 'does not save the record but returns true' do
          expect(applicant_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
