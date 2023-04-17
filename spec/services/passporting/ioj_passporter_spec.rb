require 'rails_helper'

RSpec.describe Passporting::IojPassporter do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:, ioj:) }
  let(:applicant) { instance_double(Applicant, under18?: under18) }

  let(:under18) { nil }
  let(:ioj) { nil }

  before do
    allow(crime_application).to receive(:update)
    allow(crime_application).to receive(:ioj_passport).and_return([])
  end

  describe '#call' do
    context 'when applicant is over 18' do
      let(:under18) { false }

      it 'does not add a passported type to the array' do
        expect(crime_application).to receive(:update).with({ ioj_passport: [] })
        subject.call
      end
    end

    context 'when applicant is under 18' do
      let(:under18) { true }

      it 'adds a passported type to the array' do
        expect(crime_application).to receive(:update).with({ ioj_passport: [IojPassportType::ON_AGE_UNDER18] })
        subject.call
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
end
