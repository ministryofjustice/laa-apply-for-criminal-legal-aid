require 'rails_helper'

RSpec.describe Steps::Income::EmploymentStatusForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      employment_status:,
      ended_employment_within_three_months:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { Income.new }

  let(:employment_status) { [] }
  let(:ended_employment_within_three_months) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([
                EmploymentStatus::EMPLOYED,
                EmploymentStatus::SELF_EMPLOYED,
                EmploymentStatus::BUSINESS_PARTNERSHIP,
                EmploymentStatus::DIRECTOR,
                EmploymentStatus::SHAREHOLDER,
                EmploymentStatus::NOT_WORKING
              ])
    end
  end

  describe '#save' do
    context 'when `employment_status` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:employment_status, :invalid)).to be(true)
      end
    end

    context 'when `employment_status` is not valid' do
      let(:employment_status) { ['foo'] }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:employment_status, :invalid)).to be(true)
      end

      context 'when `employment_status` selected has a valid and an invalid option' do
        let(:employment_status) { %w[foo EmploymentStatus::EMPLOYED] }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:employment_status, :invalid)).to be(true)
        end
      end
    end

    context 'when `employment_status` is valid' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:employment_status, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :income,
                      expected_attributes: {
                        'employment_status' => [EmploymentStatus::EMPLOYED.to_s],
                        'ended_employment_within_three_months' => nil
                      }

      context 'when `employment_status` answer is `employed`' do
        context 'when `ended_employment_within_three_months` was previously recorded' do
          let(:ended_employment_within_three_months) { YesNoAnswer::YES }

          it { is_expected.to be_valid }

          it 'can make ended_employment_within_three_months field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['ended_employment_within_three_months']).to be_nil
          end
        end
      end

      context 'when `employment_status` answer is `not_working`' do
        context 'when `ended_employment_within_three_months` was previously recorded' do
          let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }
          let(:ended_employment_within_three_months) { YesNoAnswer::YES }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :ended_employment_within_three_months,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `date_job_lost` as it is relevant' do
            income.update(employment_status: [EmploymentStatus::NOT_WORKING.to_s])

            attributes = form.send(:attributes_to_reset)
            expect(attributes['ended_employment_within_three_months']).to eq(ended_employment_within_three_months)
          end
        end

        context 'when a `date_job_lost` was not previously recorded' do
          let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }
          let(:ended_employment_within_three_months) { YesNoAnswer::YES.to_s }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :ended_employment_within_three_months,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end
end
