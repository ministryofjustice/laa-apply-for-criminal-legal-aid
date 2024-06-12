require 'rails_helper'

RSpec.describe Steps::Income::PartnerEmploymentStatusForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      partner_employment_status:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { Income.new }

  let(:partner_employment_status) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([
                EmploymentStatus::EMPLOYED,
                EmploymentStatus::SELF_EMPLOYED,
                EmploymentStatus::NOT_WORKING
              ])
    end
  end

  describe '#save' do
    context 'when `partner_employment_status` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:partner_employment_status, :invalid)).to be(true)
      end
    end

    context 'when `partner_employment_status` is not valid' do
      let(:partner_employment_status) { ['foo'] }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:partner_employment_status, :invalid)).to be(true)
      end
    end

    context 'when `partner_employment_status` selected has a valid and an invalid option' do
      let(:partner_employment_status) { %w[foo EmploymentStatus::EMPLOYED] }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:partner_employment_status, :invalid)).to be(true)
      end
    end

    context 'when `partner_employment_status` is valid' do
      let(:partner_employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:partner_employment_status, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'partner_employment_status' => [EmploymentStatus::EMPLOYED.to_s],
                      }
    end
  end
end
