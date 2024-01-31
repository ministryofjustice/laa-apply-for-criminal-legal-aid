require 'rails_helper'

RSpec.describe Steps::Case::IsPreorderWorkClaimedForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      is_preorder_work_claimed:,
      preorder_work_date:,
      preorder_work_details:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case:) }
  let(:case) { Case.new }

  let(:is_preorder_work_claimed) { nil }
  let(:preorder_work_date) { nil }
  let(:preorder_work_details) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `is_preorder_work_claimed` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:is_preorder_work_claimed, :inclusion)).to be(true)
      end
    end

    context 'when `is_preorder_work_claimed` is not valid' do
      let(:is_preorder_work_claimed) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:is_preorder_work_claimed, :inclusion)).to be(true)
      end
    end

    context 'when `is_preorder_work_claimed` is valid' do
      let(:is_preorder_work_claimed) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:is_preorder_work_claimed, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'is_preorder_work_claimed' => YesNoAnswer::NO,
                        'preorder_work_date' => nil,
                        'preorder_work_details' => nil
                      }

      context 'when `is_preorder_work_claimed` answer is no' do
        context 'when a `preorder_work_date` was previously recorded' do
          let(:preorder_work_date) { 1.month.ago.to_date }

          it { is_expected.to be_valid }

          it 'can make preorder_work_date and preorder_work_details field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['preorder_work_date']).to be_nil
            expect(attributes['preorder_work_details']).to be_nil
          end
        end
      end

      context 'when `is_preorder_work_claimed` answer is yes' do
        context 'when a `preorder_work_date` was previously recorded' do
          let(:is_preorder_work_claimed) { YesNoAnswer::YES.to_s }
          let(:preorder_work_date) { 1.month.ago.to_date }
          let(:preorder_work_details) { 'details text' }

          it 'is valid' do
            expect(form).to be_valid
            expect(form.errors.of_kind?(:preorder_work_date, :present)).to be(false)
            expect(form.errors.of_kind?(:preorder_work_details, :present)).to be(false)
          end

          it 'cannot reset `preorder_work_date` as it is relevant' do
            crime_application.case.update(is_preorder_work_claimed: YesNoAnswer::YES.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['preorder_work_date']).to eq(preorder_work_date)
          end
        end

        context 'when a `preorder_work_date` and `preorder_work_details` was not previously recorded' do
          let(:is_preorder_work_claimed) { YesNoAnswer::YES.to_s }
          let(:preorder_work_date) { 1.month.ago.to_date }
          let(:preorder_work_details) { 'details text' }

          it 'is also valid' do
            expect(form).to be_valid
            expect(form.errors.of_kind?(:preorder_work_date, :present)).to be(false)
            expect(form.errors.of_kind?(:preorder_work_details, :present)).to be(false)
          end
        end
      end
    end
  end
end
