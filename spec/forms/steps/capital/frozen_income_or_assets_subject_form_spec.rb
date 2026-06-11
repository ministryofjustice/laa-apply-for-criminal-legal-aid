require 'rails_helper'

RSpec.describe Steps::Capital::FrozenIncomeOrAssetsSubjectForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      frozen_income_or_assets_subject:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, capital:) }
  let(:capital) { instance_double(Capital) }

  let(:frozen_income_or_assets_subject) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq(FrozenIncomeOrAssetsSubjectType.values)
    end
  end

  describe '#save' do
    context 'when `frozen_income_or_assets_subject` is blank' do
      let(:frozen_income_or_assets_subject) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(
          form.errors.of_kind?(:frozen_income_or_assets_subject, :inclusion)
        ).to be(true)
      end
    end

    context 'when `frozen_income_or_assets_subject` is invalid' do
      let(:frozen_income_or_assets_subject) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(
          form.errors.of_kind?(:frozen_income_or_assets_subject, :inclusion)
        ).to be(true)
      end
    end

    context 'when `frozen_income_or_assets_subject` is valid' do
      let(:frozen_income_or_assets_subject) do
        FrozenIncomeOrAssetsSubjectType::CLIENT.to_s
      end

      it { is_expected.to be_valid }

      it 'updates the record' do
        expect(capital).to receive(:update)
          .with(
            {
              'frozen_income_or_assets_subject' =>
                FrozenIncomeOrAssetsSubjectType::CLIENT
            }
          )
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :capital,
                      expected_attributes: {
                        'frozen_income_or_assets_subject' =>
                          FrozenIncomeOrAssetsSubjectType::CLIENT
                      }
    end
  end
end
