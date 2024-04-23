require 'rails_helper'

RSpec.describe Steps::Income::AnswersForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { instance_double(Income) }

  describe '#save' do
    subject(:save) { form.save }

    before { allow(income).to receive(:valid?).with(:submission) { valid } }

    context 'when income is valid for submission' do
      let(:valid) { true }

      it { is_expected.to be true }
    end

    context 'when income is not valid for submission' do
      let(:valid) { false }

      it { is_expected.to be false }
    end
  end
end
