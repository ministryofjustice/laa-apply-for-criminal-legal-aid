require 'rails_helper'

RSpec.describe FulfilmentErrorsPresenter do
  subject { described_class.new(crime_application) }

  let(:crime_application) { CrimeApplication.new }

  describe '#errors' do
    context 'when there are no errors' do
      it 'returns an empty collection' do
        expect(subject.errors).to be_empty
      end
    end

    context 'when there are errors' do
      before do
        # Add a couple fake errors as an example (the attributes must exist)
        crime_application.errors.add(:means_passport, :blank, change_path: 'steps/foo/bar')
        crime_application.errors.add(:ioj_passport, :blank, change_path: 'steps/xyz')
      end

      it 'returns a collection of errors' do
        expect(subject.errors).to be_an_instance_of(Array)
      end

      context 'returned errors' do
        context 'first error' do
          let(:error) { subject.errors[0] }

          it 'contains all the information needed' do
            expect(error.attribute).to eq(:means_passport)
            expect(error.message).to eq('Applicant is not passported on means')
            expect(error.error).to eq(:blank)
            expect(error.change_path).to eq('steps/foo/bar')
          end
        end

        context 'second error' do
          let(:error) { subject.errors[1] }

          it 'contains all the information needed' do
            expect(error.attribute).to eq(:ioj_passport)
            expect(error.message).to eq('Justification for legal aid needs to be completed')
            expect(error.error).to eq(:blank)
            expect(error.change_path).to eq('steps/xyz')
          end
        end
      end
    end
  end
end
