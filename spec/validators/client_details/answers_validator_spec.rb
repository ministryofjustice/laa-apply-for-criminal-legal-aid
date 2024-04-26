require 'rails_helper'

RSpec.describe ClientDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:, applicant:, kase:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) { instance_double(Applicant, benefit_type: nil, residence_type: 'house') }
  let(:kase) { instance_double(Case, case_type: 'case_type') }

  describe '#validate' do
    context 'when validation fails' do
      before do
        allow(applicant).to receive(:values_at).with(:date_of_birth, :first_name,
                                                     :last_name).and_return(['2000-11-11', nil, 'Tim'])
        allow(applicant).to receive_messages(correspondence_address_type: nil, has_nino: nil, has_benefit_evidence: nil)
        allow(record).to receive(:kase).and_return(nil)
        allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(false)
      end

      let(:attributes) do
        {
          employment_status: nil,
          income_above_threshold: nil,
          has_frozen_income_or_assets: nil,
          has_no_income_payments: 'no',
          has_no_income_benefits: 'no',
          income_payments: [],
          income_benefits: [],
          client_has_dependants: nil,
          manage_without_income: nil
        }
      end

      it 'adds errors for all failed validations' do
        expect(errors).to receive(:add).with(:details, :blank)
        expect(errors).to receive(:add).with(:case_type, :blank)
        expect(errors).to receive(:add).with(:residence_type, :blank)
        expect(errors).to receive(:add).with(:has_nino, :blank)
        expect(errors).to receive(:add).with(:benefit_type, :blank)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end
    end
  end

  describe '#address_complete?' do
    before do
      allow(applicant).to receive(:correspondence_address_type) { correspondence_address_type }
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
      before { allow(kase).to receive(:case_type).and_return(nil) }

      it 'returns false' do
        expect(subject.case_type_complete?).to be(false)
      end
    end

    context 'when case type is present' do
      it 'returns true' do
        expect(subject.case_type_complete?).to be(true)
      end
    end
  end

  describe '#passporting_complete?' do
    context 'when benefit type is none' do
      before { allow(applicant).to receive(:benefit_type).and_return('none') }

      it 'returns true' do
        expect(subject.passporting_complete?).to be(true)
      end
    end

    context 'when evidence of passporting means is forthcoming' do
      before { allow(subject).to receive(:evidence_of_passporting_means_forthcoming?).and_return(true) }

      it 'returns true' do
        expect(subject.passporting_complete?).to be(true)
      end
    end

    context 'when Passporting::MeansPassporter returns true' do
      before do
        allow(subject).to receive(:evidence_of_passporting_means_forthcoming?).and_return(false)
        allow(Passporting::MeansPassporter).to receive(:new).and_return(double(call: true))
      end

      it 'returns true' do
        expect(subject.passporting_complete?).to be(true)
      end
    end

    context 'when Passporting::MeansPassporter returns false' do
      before do
        allow(subject).to receive(:evidence_of_passporting_means_forthcoming?).and_return(false)
        allow(Passporting::MeansPassporter).to receive(:new).and_return(double(call: false))
      end

      it 'returns false' do
        expect(subject.passporting_complete?).to be(false)
      end
    end
  end

  describe '#has_nino_complete?' do
    context 'when has NINO is missing' do
      before { allow(applicant).to receive(:has_nino).and_return(nil) }

      it 'returns false' do
        expect(subject.has_nino_complete?).to be(false)
      end
    end

    context 'when has NINO is no' do
      before { allow(applicant).to receive(:has_nino).and_return('no') }

      it 'returns true' do
        expect(subject.has_nino_complete?).to be(true)
      end
    end

    context 'when has NINO is yes but NINO is missing' do
      before do
        allow(applicant).to receive_messages(has_nino: 'yes', nino: nil)
      end

      it 'returns false' do
        expect(subject.has_nino_complete?).to be(false)
      end
    end

    context 'when has NINO is yes and NINO is present' do
      before do
        allow(applicant).to receive_messages(has_nino: 'yes', nino: 'ABC123')
      end

      it 'returns true' do
        expect(subject.has_nino_complete?).to be(true)
      end
    end
  end
end
