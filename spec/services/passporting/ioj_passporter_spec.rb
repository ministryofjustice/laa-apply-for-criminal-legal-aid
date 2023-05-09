require 'rails_helper'

RSpec.describe Passporting::IojPassporter do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:, case:, ioj:, parent_id:) }
  let(:applicant) { instance_double(Applicant, under18?: under18) }
  let(:case) { instance_double(Case, charges:) }

  let(:parent_id) { nil }
  let(:under18) { nil }
  let(:ioj) { nil }
  let(:charges) { [] }

  before do
    allow(crime_application).to receive(:ioj_passport).and_return([])
  end

  describe '#call' do
    before do
      # we test this method logic more in deep separately
      allow(subject).to receive(:offence_passported?).and_return(offence_passport)
    end

    context 'when applicant is over 18' do
      let(:under18) { false }

      context 'and none of the offences are passported' do
        let(:offence_passport) { false }

        it 'does not add any passport type to the array' do
          expect(crime_application).to receive(:update).with(
            ioj_passport: []
          )

          subject.call
        end
      end

      context 'and at least one of the offences is passported' do
        let(:offence_passport) { true }

        it 'saves the offence passport type in the array' do
          expect(crime_application).to receive(:update).with(
            ioj_passport: [IojPassportType::ON_OFFENCE]
          )

          subject.call
        end
      end
    end

    context 'when applicant is under 18' do
      let(:under18) { true }

      context 'and none of the offences are passported' do
        let(:offence_passport) { false }

        it 'saves the age passport type in the array' do
          expect(crime_application).to receive(:update).with(
            ioj_passport: [IojPassportType::ON_AGE_UNDER18]
          )

          subject.call
        end
      end

      context 'and at least one of the offences is passported' do
        let(:offence_passport) { true }

        it 'saves the age passport and the offence passport types in the array' do
          expect(crime_application).to receive(:update).with(
            ioj_passport: [IojPassportType::ON_AGE_UNDER18, IojPassportType::ON_OFFENCE]
          )

          subject.call
        end
      end
    end
  end

  describe '#passported?' do
    before do
      allow(crime_application).to receive(:ioj_passport).and_return(ioj_passport)
    end

    context 'when there is passporting of any kind' do
      let(:ioj_passport) { ['foobar'] }

      context 'passport override (split case returned applications)' do
        context 'there is no Ioj record' do
          it { expect(subject.passported?).to be(true) }
        end

        context 'there is no passport override' do
          let(:ioj) { instance_double(Ioj, passport_override: false) }

          it { expect(subject.passported?).to be(true) }
        end

        context 'there is passport override' do
          let(:ioj) { instance_double(Ioj, passport_override: true) }

          it { expect(subject.passported?).to be(false) }
        end
      end
    end

    context 'when there is no passporting' do
      let(:ioj_passport) { [] }

      it { expect(subject.passported?).to be(false) }
    end
  end

  describe '#age_passported?' do
    context 'for a new application' do
      context 'for under 18' do
        let(:under18) { true }

        it { expect(subject.age_passported?).to be(true) }
      end

      context 'for over 18' do
        let(:under18) { false }

        it { expect(subject.age_passported?).to be(false) }
      end
    end

    context 'for a resubmitted application' do
      let(:parent_id) { 'uuid' }

      before do
        allow(crime_application).to receive(:ioj_passport).and_return(ioj_passport)
      end

      context 'passported on age' do
        let(:ioj_passport) { [IojPassportType::ON_AGE_UNDER18.to_s] }

        it { expect(subject.age_passported?).to be(true) }
      end

      context 'not passported on age' do
        let(:ioj_passport) { [] }

        it { expect(subject.age_passported?).to be(false) }
      end
    end
  end

  describe '#offence_passported?' do
    before do
      allow(
        FeatureFlags.offence_ioj_passport
      ).to receive(:enabled?).and_return(feat_enabled)
    end

    context 'feature flag is disabled' do
      let(:feat_enabled) { false }

      it { expect(subject.offence_passported?).to be(false) }
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'feature flag is enabled' do
      let(:feat_enabled) { true }

      let(:passported_charge) { Charge.new(offence_name: 'Attempt robbery') }
      let(:non_passported_charge) { Charge.new(offence_name: 'Affray') }
      let(:non_listed_charge) { Charge.new(offence_name: 'This is a test offence') }

      before do
        allow(passported_charge.offence).to receive(:ioj_passport).and_return(true)
      end

      context 'when there is at least one passported offence' do
        let(:charges) { [non_passported_charge, passported_charge] }

        it { expect(subject.offence_passported?).to be(true) }
      end

      context 'when there is at least one passported offence but also non listed offences' do
        let(:charges) { [non_listed_charge, non_passported_charge, passported_charge] }

        it { expect(subject.offence_passported?).to be(true) }
      end

      context 'when there are no passported offences' do
        let(:charges) { [non_listed_charge, non_passported_charge] }

        it { expect(subject.offence_passported?).to be(false) }
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
