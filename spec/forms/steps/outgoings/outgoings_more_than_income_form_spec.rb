require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingsMoreThanIncomeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      outgoings_more_than_income:,
      how_manage:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, outgoings:) }
  let(:outgoings) { instance_double(Outgoings) }

  let(:outgoings_more_than_income) { nil }
  let(:how_manage) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `outgoings_more_than_income` is blank' do
      let(:outgoings_more_than_income) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:outgoings_more_than_income, :inclusion)).to be(true)
      end
    end

    context 'when `outgoings_more_than_income` is invalid' do
      let(:outgoings_more_than_income) { 'invalid_selection' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:outgoings_more_than_income, :inclusion)).to be(true)
      end
    end

    context 'when `outgoings_more_than_income` is `NO`' do
      let(:outgoings_more_than_income) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:outgoings_more_than_income, :invalid)).to be(false)
      end

      it 'updates the record' do
        expect(outgoings).to receive(:update)
          .with({
                  'outgoings_more_than_income' => YesNoAnswer::NO,
            'how_manage' => nil
                })
          .and_return(true)

        expect(subject.save).to be(true)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :outgoings,
                      expected_attributes: {
                        'outgoings_more_than_income' => YesNoAnswer::NO,
                        'how_manage' => nil
                      }
    end

    context 'when `outgoings_more_than_income` is `YES`' do
      let(:outgoings_more_than_income) { YesNoAnswer::YES.to_s }

      context 'when `how_manage` is blank' do
        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:how_manage, :blank)).to be(true)
        end
      end

      context 'when `how_manage` is not blank' do
        let(:how_manage) { 'A description of of they manage' }

        it 'there is no validation error on the field' do
          expect(form).to be_valid
          expect(form.errors.of_kind?(:how_manage, :blank)).to be(false)
        end
      end
    end
  end
end
