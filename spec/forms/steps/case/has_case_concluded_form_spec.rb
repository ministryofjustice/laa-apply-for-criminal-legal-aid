require 'rails_helper'

RSpec.describe Steps::Case::HasCaseConcludedForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      has_case_concluded:,
      date_case_concluded:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case:) }
  let(:case) { Case.new }

  let(:has_case_concluded) { nil }
  let(:date_case_concluded) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_case_concluded` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_case_concluded, :inclusion)).to be(true)
      end
    end

    context 'when `has_case_concluded` is not valid' do
      let(:has_case_concluded) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:has_case_concluded, :inclusion)).to be(true)
      end
    end

    context 'when `has_case_concluded` is valid' do
      let(:has_case_concluded) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:has_case_concluded, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'has_case_concluded' => YesNoAnswer::NO,
                        'date_case_concluded' => nil,
                        'is_preorder_work_claimed' => nil,
                        'preorder_work_date' => nil,
                        'preorder_work_details' => nil
                      }

      context 'when `has_case_concluded` answer is no' do
        context 'when a `date_case_concluded` was previously recorded' do
          let(:date_case_concluded) { 1.month.ago.to_date }

          it { is_expected.to be_valid }

          it 'can make date_case_concluded field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_case_concluded']).to be_nil
          end
        end
      end

      context 'when `has_case_concluded` answer is yes' do
        context 'when a `date_case_concluded` was previously recorded' do
          let(:has_case_concluded) { YesNoAnswer::YES.to_s }
          let(:date_case_concluded) { 1.month.ago.to_date }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_case_concluded,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `date_case_concluded` as it is relevant' do
            crime_application.case.update(has_case_concluded: YesNoAnswer::YES.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_case_concluded']).to eq(date_case_concluded)
          end
        end

        context 'when a `date_case_concluded` was not previously recorded' do
          let(:has_case_concluded) { YesNoAnswer::YES.to_s }
          let(:date_case_concluded) { 1.month.ago.to_date }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_case_concluded,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end
end
