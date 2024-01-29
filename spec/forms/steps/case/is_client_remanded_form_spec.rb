require 'rails_helper'

RSpec.describe Steps::Case::IsClientRemandedForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      is_client_remanded:,
      date_client_remanded:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, case:) }
  let(:case) { Case.new }

  let(:is_client_remanded) { nil }
  let(:date_client_remanded) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `is_client_remanded` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:is_client_remanded, :inclusion)).to be(true)
      end
    end

    context 'when `is_client_remanded` is not valid' do
      let(:is_client_remanded) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:is_client_remanded, :inclusion)).to be(true)
      end
    end

    context 'when `is_client_remanded` is valid' do
      let(:is_client_remanded) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:is_client_remanded, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :case,
                      expected_attributes: {
                        'is_client_remanded' => YesNoAnswer::NO,
                        'date_client_remanded' => nil
                      }

      context 'when `is_client_remanded` answer is no' do
        context 'when a `date_client_remanded` was previously recorded' do
          let(:date_client_remanded) { 1.month.ago.to_date }

          it { is_expected.to be_valid }

          it 'can make date_client_remanded field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_client_remanded']).to be_nil
          end
        end
      end

      context 'when `is_client_remanded` answer is yes' do
        context 'when a `date_client_remanded` was previously recorded' do
          let(:is_client_remanded) { YesNoAnswer::YES.to_s }
          let(:date_client_remanded) { 1.month.ago.to_date }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_client_remanded,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `date_client_remanded` as it is relevant' do
            crime_application.case.update(is_client_remanded: YesNoAnswer::YES.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_client_remanded']).to eq(date_client_remanded)
          end
        end

        context 'when a `date_client_remanded` was not previously recorded' do
          let(:is_client_remanded) { YesNoAnswer::YES.to_s }
          let(:date_client_remanded) { 1.month.ago.to_date }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_client_remanded,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end
end
