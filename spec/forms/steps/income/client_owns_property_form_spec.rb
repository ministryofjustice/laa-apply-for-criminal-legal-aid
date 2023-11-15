require 'rails_helper'

RSpec.describe Steps::Income::ClientOwnsPropertyForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      client_owns_property:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income_details:) }
  let(:income_details) { instance_double(IncomeDetails) }

  let(:client_owns_property) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `client_owns_property` is blank' do
      let(:client_owns_property) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:client_owns_property, :inclusion)).to be(true)
      end
    end

    context 'when `client_owns_property` is invalid' do
      let(:client_owns_property) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:client_owns_property, :inclusion)).to be(true)
      end
    end

    context 'when `client_owns_property` is valid' do
      let(:client_owns_property) { YesNoAnswer::YES.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:client_owns_property, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(income_details).to receive(:update)
          .with({ 'client_owns_property' => YesNoAnswer::YES })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income_details,
                      expected_attributes: {
                        'client_owns_property' => YesNoAnswer::YES,
                      }
    end
  end
end
