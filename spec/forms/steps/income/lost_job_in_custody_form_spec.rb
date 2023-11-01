require 'rails_helper'

RSpec.describe Steps::Income::LostJobInCustodyForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      employment_status:,
      ended_employment_with_three_months:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant_record) }
  let(:applicant_record) { Applicant.new }

  let(:employment_status) { nil }
  let(:ended_employment_with_three_months) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `lost_job_in_custody` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:lost_job_in_custody, :inclusion)).to be(true)
      end
    end

    context 'when `lost_job_in_custody` is not valid' do
      let(:lost_job_in_custody) { 'maybe' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:lost_job_in_custody, :inclusion)).to be(true)
      end
    end

    context 'when `lost_job_in_custody` is valid' do
      let(:lost_job_in_custody) { YesNoAnswer::NO.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:lost_job_in_custody, :invalid)).to be(false)
      end

      it_behaves_like 'a has-one-association form',
                      association_name: :applicant,
                      expected_attributes: {
                        'lost_job_in_custody' => YesNoAnswer::NO,
                        'date_job_lost' => nil
                      }

      context 'when `lost_job_in_custody` answer is no' do
        context 'when a `date_job_lost` was previously recorded' do
          let(:date_job_lost) { 1.month.ago.to_date }

          it { is_expected.to be_valid }

          it 'can make date_job_lost field nil if no longer required' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_job_lost']).to be_nil
          end
        end
      end

      context 'when `lost_job_in_custody` answer is yes' do
        context 'when a `date_job_lost` was previously recorded' do
          let(:lost_job_in_custody) { YesNoAnswer::YES.to_s }
          let(:date_job_lost) { 1.month.ago.to_date }

          it 'is valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_job_lost,
                :present
              )
            ).to be(false)
          end

          it 'cannot reset `date_job_lost` as it is relevant' do
            applicant_record.update(lost_job_in_custody: YesNoAnswer::YES.to_s)

            attributes = form.send(:attributes_to_reset)
            expect(attributes['date_job_lost']).to eq(date_job_lost)
          end
        end

        context 'when a `date_job_lost` was not previously recorded' do
          let(:lost_job_in_custody) { YesNoAnswer::YES.to_s }
          let(:date_job_lost) { 1.month.ago.to_date }

          it 'is also valid' do
            expect(form).to be_valid
            expect(
              form.errors.of_kind?(
                :date_job_lost,
                :present
              )
            ).to be(false)
          end
        end
      end
    end
  end
end
