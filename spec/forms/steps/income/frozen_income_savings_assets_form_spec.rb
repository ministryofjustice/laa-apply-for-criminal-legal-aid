require 'rails_helper'

RSpec.describe Steps::Income::FrozenIncomeSavingsAssetsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_frozen_income_or_assets:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { instance_double(Income) }

  let(:has_frozen_income_or_assets) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_frozen_income_or_assets` is blank' do
      let(:has_frozen_income_or_assets) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_frozen_income_or_assets, :inclusion)).to be(true)
      end
    end

    context 'when `has_frozen_income_or_assets` is invalid' do
      let(:has_frozen_income_or_assets) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_frozen_income_or_assets, :inclusion)).to be(true)
      end
    end

    context 'when `has_frozen_income_or_assets` is valid' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:has_frozen_income_or_assets, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(income).to receive(:update)
          .with({ 'has_frozen_income_or_assets' => YesNoAnswer::YES })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'has_frozen_income_or_assets' => YesNoAnswer::YES,
                      }
    end
  end
end
