require 'rails_helper'

RSpec.describe Steps::Case::UrnForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
    urn:
    }
  end

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  let(:urn) { nil }

  describe '#save' do
    context 'when `urn` is blank' do
      let(:urn) { '' }

      it 'has no validation error on the field' do
        expect(subject).to be_valid
        expect(subject.errors.of_kind?(:urn, :invalid)).to be(false)
      end
    end

    context 'when `urn` is invalid' do
      let(:urn) { 'urn' }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:urn, :invalid)).to be(true)
      end
    end

    context 'when `urn` is valid' do
      context 'with spaces between numbers' do
        let(:urn) { '12 AB 34 56 78 9' }

        it 'passes validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:urn, :invalid)).to be(false)
        end

        it 'removes spaces from input' do
          expect(subject.urn).to eq('12AB3456789')
        end
      end

      context 'with trailing spaces' do
        let(:urn) { ' 12 AB 34 56789 ' }

        it 'passed validation' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:urn, :invalid)).to be(false)
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
