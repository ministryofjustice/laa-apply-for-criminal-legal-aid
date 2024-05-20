require 'rails_helper'

RSpec.describe Steps::Income::Client::DeductionsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: employment,
      income_tax: income_tax,
      national_insurance: national_insurance,
      types: types,
      other: other
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:employment) { Employment.create!(crime_application:) }
  let(:income_tax) { { amount: 500, frequency: 'four_weeks', employment_id: employment.id } }
  let(:national_insurance) { { amount: '', frequency: '', employment_id: employment.id } }
  let(:other) { { amount: 300, frequency: 'week', employment_id: employment.id, details: 'other deduction details' } }
  let(:types) { %w[income_tax other] }

  describe '#save' do
    context 'when valid attributes are provided' do
      it 'returns true' do
        expect(form.save).to be(true)
      end

      it 'create and return ordered associated deductions' do
        expect(form.employment.deductions.count).to eq(2)
        expect(form.employment.deductions.first).to have_attributes({ deduction_type: 'income_tax',
                                                                      amount: 500,
                                                                      frequency: 'four_weeks',
                                                                      details: nil })
        expect(form.employment.deductions.second).to have_attributes({ deduction_type: 'other',
                                                                 amount: 300,
                                                                 frequency: 'week',
                                                                 details: 'other deduction details' })
        expect(form.employment.has_no_deductions).to be_nil
      end

      context 'when `type` is none' do
        let(:types) { ['none'] }

        it 'returns true and update employment.has_no_deductions to `yes`' do
          expect(form.save).to be(true)
          expect(form.employment.has_no_deductions).to eq('yes')
        end
      end

      context 'when has_no_deductions is already set to `yes`' do
        before do
          employment.update(has_no_deductions: 'yes')
        end

        it 'returns true and update employment.has_no_deductions to nil' do
          expect(form.save).to be(true)
          expect(form.employment.has_no_deductions).to be_nil
        end
      end

      context 'when deduction type is already present for an employment' do
        before do
          employment.deductions.create!(deduction_type: 'income_tax', amount: 100, frequency: 'week')
        end

        it 'returns true, update employment.has_no_deductions to nil, remove old deduction and create new deduction' do
          expect(form.save).to be(true)
          expect(form.employment.has_no_deductions).to be_nil
          expect(form.employment.deductions.count).to eq(2)
          expect(form.employment.deductions.first).to have_attributes({ deduction_type: 'income_tax',
                                                                        amount: 500,
                                                                        frequency: 'four_weeks',
                                                                        details: nil })
        end
      end

      context 'when updating all existing deductions for an employment' do
        before do
          employment.deductions
                    .create!(deduction_type: 'income_tax', amount: 1, frequency: 'week', details: nil)
          employment.deductions
                    .create!(deduction_type: 'national_insurance', amount: 2, frequency: 'week', details: nil)
          employment.deductions
                    .create!(deduction_type: 'other', amount: 3, frequency: 'week', details: nil)
        end

        let(:types) { %w[income_tax national_insurance other] }
        let(:national_insurance) { { amount: 400, frequency: 'week', employment_id: employment.id } }

        it 'returns true, update employment.has_no_deductions to nil, create new deduction' do
          expect(form.save).to be(true)
          expect(form.employment.has_no_deductions).to be_nil
          expect(form.employment.deductions.count).to eq(3)
          expect(form.employment.deductions.first).to have_attributes({ deduction_type: 'income_tax',
                                                                        amount: 500,
                                                                        frequency: 'four_weeks',
                                                                        details: nil })
          expect(form.employment.deductions.second).to have_attributes({ deduction_type: 'national_insurance',
                                                                        amount: 400,
                                                                        frequency: 'week',
                                                                        details: nil })
          expect(form.employment.deductions.third).to have_attributes({ deduction_type: 'other',
                                                                        amount: 300,
                                                                        frequency: 'week',
                                                                        details: 'other deduction details' })
        end
      end
    end

    context 'when `type` is not provided' do
      let(:types) { [] }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:base, :none_selected)).to be(true)
      end
    end

    context 'when `type` is nil' do
      let(:types) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:base, :none_selected)).to be(true)
      end
    end

    context 'when type is not provided' do
      before {
        arguments.except!(:types)
      }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        form.save
        expect(form).not_to be_valid

        expect(form.errors.of_kind?(:base, :none_selected)).to be(true)
      end
    end

    context 'when income_tax amount is not provided' do
      before { income_tax.merge!(amount: nil) }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        form.save
        expect(form).not_to be_valid
        expect(form.errors.of_kind?('income-tax-amount', :not_a_number)).to be(true)
      end
    end

    context 'when type includes other details is not provided' do
      before { other.merge!(details: nil) }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        form.save
        expect(form).not_to be_valid
        expect(form.errors.of_kind?('other-details', :blank)).to be(true)
      end
    end
  end

  describe '#ordered_deductions' do
    it 'returns the sorted deductions' do
      expect(form.ordered_deductions).to eq([
                                              DeductionType::INCOME_TAX.to_s,
                                              DeductionType::NATIONAL_INSURANCE.to_s,
                                              DeductionType::OTHER.to_s
                                            ])
    end
  end
end
