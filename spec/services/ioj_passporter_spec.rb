require 'rails_helper'

RSpec.describe IojPassporter do
  subject { described_class.new(applicant, kase) }

  let(:kase) { instance_double(Case) }
  let(:applicant) { instance_double(Applicant, date_of_birth: applicant_dob) }
  let(:applicant_dob) { nil }

  before do
    allow(kase).to receive(:update)
    allow(kase).to receive(:ioj_passport).and_return([])
  end

  describe '#call' do
    context 'when applicant is over 18' do
      let(:applicant_dob) { Date.new(1990, 1, 1) }

      it 'does not add a passported type to the case ioj' do
        expect(kase).not_to receive(:update)
        subject.call
      end
    end

    context 'when applicant is under 18' do
      let(:applicant_dob) { Time.zone.today }

      it 'adds a passported type to the case ioj' do
        expect(kase).to receive(:update).with({ ioj_passport: instance_of(Array) })
        subject.call
      end
    end
  end
end
