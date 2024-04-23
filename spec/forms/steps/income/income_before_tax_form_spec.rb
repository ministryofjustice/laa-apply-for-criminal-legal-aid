require 'rails_helper'

RSpec.describe Steps::Income::IncomeBeforeTaxForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      income_above_threshold:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { instance_double(Income) }

  let(:income_above_threshold) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `income_above_threshold` is blank' do
      let(:income_above_threshold) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:income_above_threshold, :inclusion)).to be(true)
      end
    end

    context 'when `income_above_threshold` is invalid' do
      let(:income_above_threshold) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:income_above_threshold, :inclusion)).to be(true)
      end
    end

    context 'when `income_above_threshold` is valid' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:income_above_threshold, :invalid)).to be(false)
      end

      it 'updates the record and resets relevant attributes' do
        expect(income).to receive(:update)
          .with({ 'income_above_threshold' => YesNoAnswer::YES,
                  'client_owns_property' => nil,
                  'has_frozen_income_or_assets' => nil,
                  'has_savings' => nil })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'income_above_threshold' => YesNoAnswer::YES,
                        'client_owns_property' => nil,
                        'has_frozen_income_or_assets' => nil,
                        'has_savings' => nil,
                      }

      context 'when `income_above_threshold` answer is no' do
        let(:income_above_threshold) { YesNoAnswer::NO.to_s }

        it 'updates the record' do
          expect(income).to receive(:update)
            .with({ 'income_above_threshold' => YesNoAnswer::NO })
            .and_return(true)

          expect(subject.save).to be(true)
        end

        it_behaves_like 'a has-one-association form',
                        association_name: :income,
                        expected_attributes: { 'income_above_threshold' => YesNoAnswer::NO }
      end
    end
  end
end
