require 'rails_helper'

RSpec.describe EmploymentDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) do
    instance_double(
      Income,
      errors:,
      crime_application:,
      employment_status:,
      partner_employment_status:
    )
  end

  let(:errors) { double(:errors, empty?: false) }
  let(:crime_application) { instance_double(CrimeApplication, partner_detail:) }
  let(:employment_status) { [] }
  let(:partner_employment_status) { nil }
  let(:partner_detail) { nil }

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when means assessment required' do
      before do
        allow(validator).to receive(:requires_means_assessment?).and_return(true)
      end

      it { is_expected.to be(true) }
    end

    context 'when means assessment not required' do
      before do
        allow(validator).to receive(:requires_means_assessment?).and_return(false)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    context 'when no employment status' do
      it { is_expected.to be(false) }
    end

    context 'when working' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      it { is_expected.to be(true) }
    end

    context 'when not working' do
      let(:employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }
      let(:ended_employment_within_three_months) { 'yes' }
      let(:lost_job_in_custody) { 'yes' }
      let(:date_job_lost) { '2000-01-01' }

      before do
        allow(record).to receive_messages(
          ended_employment_within_three_months:,
          lost_job_in_custody:,
          date_job_lost:
        )
      end

      it { is_expected.to be(true) }

      context 'when lost in custody date is missing' do
        let(:date_job_lost) { nil }

        it { is_expected.to be(false) }
      end

      context 'when ended employment within three months not answered' do
        let(:ended_employment_within_three_months) { nil }

        it { is_expected.to be(false) }
      end

      context 'when not ended employment within last three months' do
        let(:ended_employment_within_three_months) { 'no' }
        let(:lost_job_in_custody) { nil }
        let(:date_job_lost) { nil }

        it { is_expected.to be(true) }

        context 'when partner employment status is not answered' do
          let(:partner_detail) { double(PartnerDetail, involvement_in_case: 'none') }
          let(:partner_employment_status) { nil }

          it { is_expected.to be(false) }

          context 'when partner employment status is answered' do # rubocop:disable RSpec/NestedGroups
            let(:partner_employment_status) { [EmploymentStatus::NOT_WORKING.to_s] }

            it { is_expected.to be(true) }
          end
        end
      end
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

    context 'when not applicable' do
      before do
        allow(validator).to receive(:applicable?).and_return(false)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context 'when applicable' do
      before do
        allow(validator).to receive(:applicable?).and_return(true)
      end

      it 'adds errors to :appeal_details when incomplete' do
        allow(validator).to receive(:complete?).and_return(false)
        expect(errors).to receive(:add).with(:employment_status, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        validate
      end

      it 'does not add errors when complete' do
        allow(validator).to receive(:complete?).and_return(true)
        expect(errors).not_to receive(:add)

        validate
      end
    end
  end
end
