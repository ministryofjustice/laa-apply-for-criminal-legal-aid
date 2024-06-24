require 'rails_helper'

RSpec.describe ClientDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record: record, crime_application: record) }

  let(:record) { instance_double(CrimeApplication, errors:, applicant:, kase:, client_has_partner:, partner_detail:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) { instance_double(Applicant, residence_type: 'house', under18?: under18?) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:appeal_no_changes?) { false }
  let(:under18?) { false }
  let(:case_type) { nil }
  let(:client_has_partner) { nil }
  let(:partner_detail) { nil }

  before do
    allow(validator).to receive(:appeal_no_changes?) { appeal_no_changes? }
  end

  describe '#validate' do
    context 'when validation fails' do
      before do
        allow(applicant).to receive(:values_at).with(
          :date_of_birth, :first_name, :last_name
        ).and_return(['2000-11-11', 'Tim', nil])

        allow(applicant).to receive_messages(correspondence_address_type: nil, has_nino: nil)
        allow(record).to receive(:kase).and_return(nil)
      end

      it 'adds errors for all failed validations' do
        expect(errors).to receive(:add).with(:details, :blank)
        expect(errors).to receive(:add).with(:case_type, :blank)
        expect(errors).to receive(:add).with(:residence_type, :blank)
        expect(errors).to receive(:add).with(:has_nino, :blank)
        expect(errors).to receive(:add).with(:client_has_partner, :blank)
        expect(errors).to receive(:add).with(:relationship_status, :blank)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end

      context 'when application is appeal to crown court no changes' do
        let(:appeal_no_changes?) { true }

        it 'adds any errors for details and case type' do
          expect(errors).to receive(:add).with(:details, :blank)
          expect(errors).to receive(:add).with(:case_type, :blank)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when applicant is under 18' do
        let(:under18?) { true }

        it 'adds any errors for details, case type and residence type' do
          expect(errors).to receive(:add).with(:details, :blank)
          expect(errors).to receive(:add).with(:case_type, :blank)
          expect(errors).to receive(:add).with(:residence_type, :blank)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end
    end
  end

  describe '#address_complete?' do
    before do
      allow(applicant).to receive(:correspondence_address_type) { correspondence_address_type }
    end

    context 'when appeal_no_changes' do
      let(:correspondence_address_type) { nil }
      let(:appeal_no_changes?) { true }

      it { expect(subject.address_complete?).to be(true) }
    end

    context 'when we have completed mandatory contact details' do
      context 'for a home address' do
        let(:correspondence_address_type) { CorrespondenceType::HOME_ADDRESS.to_s }

        before do
          allow(applicant).to receive(:home_address?).and_return(true)
        end

        it { expect(subject.address_complete?).to be(true) }

        context 'when residence_type is nil' do
          before do
            allow(applicant).to receive(:residence_type).and_return(nil)
          end

          it { expect(subject.address_complete?).to be(false) }
        end
      end

      context 'for other address' do
        let(:correspondence_address_type) { CorrespondenceType::OTHER_ADDRESS.to_s }

        before do
          allow(applicant).to receive(:correspondence_address?).and_return(true)
        end

        it { expect(subject.address_complete?).to be(true) }
      end

      context 'for providers address' do
        let(:correspondence_address_type) { CorrespondenceType::PROVIDERS_OFFICE_ADDRESS.to_s }

        before do
          allow(applicant).to receive(:correspondence_address?).and_return(true)
        end

        it { expect(subject.address_complete?).to be(true) }
      end
    end
  end

  describe '#applicant_details_complete?' do
    before do
      allow(applicant).to receive(:values_at).with(:date_of_birth, :first_name, :last_name).and_return(values_at)
    end

    context 'when attributes are missing' do
      let(:values_at) { [nil, 'a'] }

      it 'returns false' do
        expect(subject.applicant_details_complete?).to be(false)
      end
    end

    context 'when all details are present' do
      let(:values_at) { [1, 'a'] }

      it 'returns true' do
        expect(subject.applicant_details_complete?).to be(true)
      end
    end
  end

  describe '#case_type_complete?' do
    context 'when case type is missing' do
      let(:case_type) { nil }

      it 'returns false' do
        expect(subject.case_type_complete?).to be(false)
      end
    end

    context 'when case type is present' do
      let(:case_type) { CaseType::EITHER_WAY }

      it 'returns true' do
        expect(subject.case_type_complete?).to be(true)
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers

  describe '#has_nino_complete?' do
    let(:has_nino) { nil }
    let(:nino) { nil }
    let(:will_enter_nino) { nil }

    before do
      allow(applicant).to receive_messages(has_nino:, nino:)
    end

    context 'when has NINO is missing' do
      it 'returns false' do
        expect(subject.has_nino_complete?).to be(false)
      end
    end

    context 'when has NINO is no' do
      let(:has_nino) { 'no' }

      it 'returns true' do
        expect(subject.has_nino_complete?).to be(true)
      end
    end

    context 'when has NINO is yes but NINO is missing' do
      let(:has_nino) { 'yes' }

      it 'returns false' do
        expect(subject.has_nino_complete?).to be(false)
      end
    end

    context 'when has NINO is yes and NINO is present' do
      let(:has_nino) { 'yes' }
      let(:nino) { 'ABC12312' }

      it 'returns true' do
        expect(subject.has_nino_complete?).to be(true)
      end
    end
  end

  describe '#relationship_status_complete?' do
    context 'when applicant under18' do
      let(:client_has_partner) { nil } # Should not be possible
      let(:under18?) { true }

      it 'returns true' do
        expect(subject.relationship_status_complete?).to be(true)
      end
    end

    context 'when applicant has partner' do
      let(:client_has_partner) { 'yes' }

      it 'returns true' do
        expect(subject.relationship_status_complete?).to be(true)
      end
    end

    context 'when applicant does not have partner' do
      let(:client_has_partner) { 'no' }
      let(:partner_detail) do
        instance_double(
          PartnerDetail,
          relationship_status: 'divorced'
        )
      end

      it 'returns true' do
        expect(subject.relationship_status_complete?).to be(true)
      end
    end
  end

  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
