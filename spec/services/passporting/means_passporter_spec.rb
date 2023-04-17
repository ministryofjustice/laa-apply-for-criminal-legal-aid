require 'rails_helper'

RSpec.describe Passporting::MeansPassporter do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant, under18?: under18, passporting_benefit: passporting_benefit) }

  let(:under18) { nil }
  let(:passporting_benefit) { nil }

  before do
    allow(crime_application).to receive(:update)
    allow(crime_application).to receive(:means_passport).and_return([])
  end

  describe '#call' do
    context 'means passporting on age' do
      context 'when applicant is over 18' do
        let(:under18) { false }

        it 'does not add an age passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end

      context 'when applicant is under 18' do
        let(:under18) { true }

        it 'adds an age passported type to the array' do
          expect(
            crime_application
          ).to receive(:update).with(
            means_passport: [MeansPassportType::ON_AGE_UNDER18]
          )

          subject.call
        end
      end
    end

    context 'means passporting on benefit checker' do
      let(:under18) { false }

      context 'when DWP benefit check has been successful' do
        let(:passporting_benefit) { true }

        it 'adds a benefit passported type to the array' do
          expect(
            crime_application
          ).to receive(:update).with(
            means_passport: [MeansPassportType::ON_BENEFIT_CHECK]
          )

          subject.call
        end
      end

      context 'when DWP benefit check has failed' do
        let(:passporting_benefit) { false }

        it 'does not add a benefit passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end

      context 'when DWP benefit check has not been performed' do
        let(:passporting_benefit) { nil }

        it 'does not add a benefit passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end
    end
  end

  describe '#passported?' do
    before do
      allow(crime_application).to receive(:means_passport).and_return(means_passport)
    end

    context 'when there is passporting of any kind' do
      let(:means_passport) { ['foobar'] }

      it { expect(subject.passported?).to be(true) }
    end

    context 'when there is no passporting' do
      let(:means_passport) { [] }

      it { expect(subject.passported?).to be(false) }
    end
  end
end
