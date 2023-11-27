require 'rails_helper'

RSpec.describe Steps::Income::ManageWithoutIncomeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      manage_without_income:,
      manage_other_details:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { Income.new }

  let(:manage_without_income) { nil }
  let(:manage_other_details) { nil }

  describe '#save' do
    context 'when `manage_without_income` is blank' do
      let(:manage_without_income) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:manage_without_income, :inclusion)).to be(true)
      end
    end

    context 'when `manage_without_income` is invalid' do
      let(:manage_without_income) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:manage_without_income, :inclusion)).to be(true)
      end
    end

    context 'when `manage_without_income` is valid' do
      let(:manage_without_income) { ManageWithoutIncomeType::FAMILY.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:manage_without_income, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'manage_without_income' => ManageWithoutIncomeType::FAMILY,
                        'manage_other_details' => nil
                      }

      context 'when selection is other' do
        let(:manage_without_income) { ManageWithoutIncomeType::OTHER.to_s }
        let(:manage_other_details) { 'details' }

        it 'is valid' do
          expect(form).to be_valid
          expect(
            form.errors.of_kind?(
              :manage_other_details,
              :present
            )
          ).to be(false)
        end

        it 'cannot reset `manage_other_details` as it is relevant' do
          income.update(manage_without_income: ManageWithoutIncomeType::OTHER.to_s)

          attributes = form.send(:attributes_to_reset)
          expect(attributes['manage_other_details']).to eq(manage_other_details)
        end
      end

      context 'when `manage_other_details` answer is not `other`' do
        context 'when `manage_other_details` was previously recorded' do
          let(:manage_other_details) { 'details' }

          it { is_expected.to be_valid }

          it 'can make manage_other_details field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['manage_other_details']).to be_nil
          end
        end
      end
    end
  end
end
