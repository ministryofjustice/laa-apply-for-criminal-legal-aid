require 'rails_helper'

RSpec.describe Steps::Income::ClientHasDependantsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      client_has_dependants:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { instance_double(Income) }

  let(:client_has_dependants) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `client_has_dependants` is blank' do
      let(:client_has_dependants) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:client_has_dependants, :inclusion)).to be(true)
      end
    end

    context 'when `client_has_dependants` is invalid' do
      let(:client_has_dependants) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:client_has_dependants, :inclusion)).to be(true)
      end
    end

    context 'when `client_has_dependants` is valid' do
      let(:client_has_dependants) { YesNoAnswer::YES.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:client_has_dependants, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(income).to receive(:update)
          .with({ 'client_has_dependants' => YesNoAnswer::YES })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'client_has_dependants' => YesNoAnswer::YES,
                      }
    end
  end
end
