require 'rails_helper'

RSpec.describe Steps::Income::FrozenIncomeOrAssetsSubjectForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      frozen_income_or_assets_subject:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { Income.new }

  let(:frozen_income_or_assets_subject) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([
                FrozenIncomeOrAssetsSubjectType::APPLICANT,
                FrozenIncomeOrAssetsSubjectType::PARTNER,
                FrozenIncomeOrAssetsSubjectType::APPLICANT_AND_PARTNER
              ])
    end
  end

  describe '#save' do
    context 'when `frozen_income_or_assets_subject` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
      end
    end

    context 'when `frozen_income_or_assets_subject` is not valid' do
      let(:frozen_income_or_assets_subject) { 'foo' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(
          form.errors.of_kind?(:frozen_income_or_assets_subject, :inclusion)
        ).to be(true)
      end
    end

    context 'when `frozen_income_or_assets_subject` is applicant' do
      let(:frozen_income_or_assets_subject) do
        FrozenIncomeOrAssetsSubjectType::APPLICANT.to_s
      end

      it { is_expected.to be_valid }

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'frozen_income_or_assets_subject' => FrozenIncomeOrAssetsSubjectType::APPLICANT
                      }
    end

    context 'when `frozen_income_or_assets_subject` is partner' do
      let(:frozen_income_or_assets_subject) do
        FrozenIncomeOrAssetsSubjectType::PARTNER.to_s
      end

      it { is_expected.to be_valid }

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'frozen_income_or_assets_subject' => FrozenIncomeOrAssetsSubjectType::PARTNER
                      }
    end

    context 'when `frozen_income_or_assets_subject` is client_and_partner' do
      let(:frozen_income_or_assets_subject) do
        FrozenIncomeOrAssetsSubjectType::APPLICANT_AND_PARTNER.to_s
      end

      it { is_expected.to be_valid }

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'frozen_income_or_assets_subject' => FrozenIncomeOrAssetsSubjectType::APPLICANT_AND_PARTNER
                      }
    end
  end
end
