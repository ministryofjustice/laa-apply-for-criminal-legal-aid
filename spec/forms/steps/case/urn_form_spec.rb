require 'rails_helper'

RSpec.describe Steps::Case::UrnForm do

  let(:arguments) { {
    crime_application: crime_application,
    urn: urn
  } }

  let(:crime_application) { 
    instance_double(CrimeApplication)
  }

  let(:urn) { nil }

  subject { described_class.new(arguments) }

  describe '#save' do
    context 'when `urn` is blank' do
      let(:urn) { '' }

      it 'has no validation error on the field' do
        expect(subject).to be_valid
        expect(subject.errors.of_kind?(:urn, :invalid)).to eq(false)
      end
    end

    context 'when `urn` is invalid' do
      let(:urn) { 'not a urn' }

      it 'has a validation error on the field' do
        expect(subject).to_not be_valid
        expect(subject.errors.of_kind?(:urn, :invalid)).to eq(true)
      end
    end

    context 'when `urn` is valid' do
      context 'with spaces between numbers' do
        let(:urn) { '12 AB 34 56 78 9' }
        it 'passes validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:urn, :invalid)).to eq(false)
        end
        it 'removes spaces from input' do
          expect(subject.urn).to eq('12AB3456789')
        end
      end

      context 'with trailing spaces' do
        let(:urn) { ' 12 AB 34 56789 ' }
        it 'passed validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:urn, :invalid)).to eq(false)
        end
      end
    end

    context 'when validations pass' do
      let(:urn) { '12AB3456789' }
      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'urn' => '12AB3456789'
                      }
    end
  end
end
