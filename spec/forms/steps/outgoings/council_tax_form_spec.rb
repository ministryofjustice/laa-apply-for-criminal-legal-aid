require 'rails_helper'

RSpec.describe Steps::Outgoings::CouncilTaxForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      pays_council_tax:,
      council_tax_amount_in_pounds:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, outgoings:) }
  let(:outgoings) { Outgoings.new }

  let(:pays_council_tax) { nil }
  let(:council_tax_amount_in_pounds) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `pays_council_tax` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:pays_council_tax, :inclusion)).to be(true)
      end
    end

    context 'when `pays_council_tax` is not valid' do
      let(:pays_council_tax) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:pays_council_tax, :inclusion)).to be(true)
      end
    end

    context 'when `pays_council_tax` is valid' do
      let(:pays_council_tax) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:pays_council_tax, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :outgoings,
                      expected_attributes: {
                        'pays_council_tax' => YesNoAnswer::NO,
                        'council_tax_amount' => nil
                      }

      context 'when `pays_council_tax` answer is no' do
        let(:pays_council_tax) { YesNoAnswer::NO.to_s }

        context 'when a `council_tax_amount` was previously recorded' do
          before do
            outgoings.update(council_tax_amount: 100_079)
          end

          it { is_expected.to be_valid }

          it 'can make council_tax_amount field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['council_tax_amount']).to be_nil
          end
        end
      end

      context 'when `pays_council_tax` answer is yes' do
        context 'when a `council_tax_amount` was previously recorded' do
          let(:pays_council_tax) { YesNoAnswer::YES.to_s }
          let(:council_tax_amount_in_pounds) { 1000.79 }

          before do
            outgoings.update(pays_council_tax: YesNoAnswer::YES.to_s)
            outgoings.update(council_tax_amount: 100_079)
          end

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :council_tax_amount_in_pounds,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `council_tax_amount` as it is relevant' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['council_tax_amount']).to eq(100_079)
          end
        end

        context 'when a `council_tax_amount` was not previously recorded' do
          let(:pays_council_tax) { YesNoAnswer::YES.to_s }
          let(:council_tax_amount_in_pounds) { 1000.79 }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :council_tax_amount_in_pounds,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end
end
