require 'rails_helper'

RSpec.describe Steps::Outgoings::AnswersForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, outgoings:) }
  let(:outgoings) { instance_double(Outgoings) }

  describe '#save' do
    subject(:save) { form.save }

    before { allow(outgoings).to receive(:valid?).with(:submission) { valid } }

    context 'when outgoings is valid for submission' do
      let(:valid) { true }

      it { is_expected.to be true }
    end

    context 'when outgoings is not valid for submission' do
      let(:valid) { false }

      it { is_expected.to be false }
    end
  end
end
