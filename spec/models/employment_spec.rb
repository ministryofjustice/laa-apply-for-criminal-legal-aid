require 'rails_helper'

RSpec.describe Employment, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      crime_application_id: double(CrimeApplication, id: 1).id,
      ownership_type: 'applicant',
      employer_name: 'Driscoll Bruce',
      address: address_attributes,
      job_title: 'Manager',
      has_no_deductions: nil,
      amount: 500,
      frequency: 'week',
      before_or_after_tax: BeforeOrAfterTax::BEFORE,
      deductions: [deduction]
    }
  end

  let(:address_attributes) do
    {
      address_line_one: 'address_line_one',
      address_line_two: 'address_line_two',
      city: 'city',
      country: 'country',
      postcode: 'postcode'
    }.as_json
  end

  let(:deduction_attributes) do
    {
      deduction_type: 'income_tax',
      amount: 500,
      frequency: 'week'
    }
  end

  let(:metadata) do
    {
      before_or_after_tax: { value: 'before_tax' }
    }.as_json
  end

  let(:deduction) { Deduction.new(deduction_attributes) }

  describe '#complete?' do
    context 'with valid attributes' do
      it 'returns true' do
        expect(subject.complete?).to be(true)
        expect(subject.deductions.complete).to eq([deduction])
      end

      context 'when has_no_deductions set to `yes`' do
        before { attributes.merge!(has_no_deductions: 'yes', deductions: []) }

        it 'returns true' do
          expect(subject.complete?).to be(true)
        end
      end
    end

    context 'with invalid attributes' do
      context 'when employer_name is nil' do
        before { attributes.merge!(employer_name: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when deductions are missing' do
        before { attributes.merge!(deductions: []) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when deductions are incomplete' do
        before { deduction_attributes.merge!(amount: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when address is missing' do
        before { attributes.merge!(address: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when address is incomplete' do
        before { address_attributes.merge!(postcode: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end

      context 'when before_or_after_tax is missing' do
        before { attributes.merge!(before_or_after_tax: nil) }

        it 'returns false' do
          expect(subject.complete?).to be(false)
        end
      end
    end
  end
end
