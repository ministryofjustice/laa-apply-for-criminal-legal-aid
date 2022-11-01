require 'rails_helper'

RSpec.describe IojPassporter do
  subject { described_class.new(applicant, kase) }

  let(:kase) { instance_double(Case, ioj:) }
  let(:applicant) { instance_double(Applicant, date_of_birth: applicant_dob) }
  let(:applicant_dob) { nil }
  let(:ioj) { nil }

  before do
    allow(kase).to receive(:update)
  end

  describe '#call' do
    context 'when applicant is over 18' do
      context 'and has not been previously passported' do
        let(:applicant_dob) { Date.new(1990, 1, 1) }

        it 'adds a passported type to the case ioj' do
          expect(kase).not_to receive(:update)
          subject.call
        end
      end

      context 'and has previously been passported' do
        let(:applicant_dob) { Date.new(1990, 1, 1) }
        let(:ioj) { instance_double(Ioj, types: ['passported']) }

        it 'removes the ioj' do
          expect(kase).to receive(:update)
          subject.call
        end
      end
    end

    context 'when applicant is under 18' do
      let(:applicant_dob) { Time.zone.today }

      it 'adds a passported type to the case ioj' do
        expect(kase).to receive(:update).with({ ioj: instance_of(Ioj) })
        subject.call
      end
    end
  end
end
