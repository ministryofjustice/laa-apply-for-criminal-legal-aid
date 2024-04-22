require 'rails_helper'

RSpec.describe Steps::Submission::ReviewForm do
  subject { described_class.new(arguments) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:arguments) { { crime_application: } }

  describe '#save' do
    context 'when no submission validation issues' do
      before do
        allow(crime_application).to receive(:valid?).with(:submission).and_return(true)
      end

      it 'succeeds' do
        expect(subject.save).to be true
      end
    end

    context 'when submission validation issues' do
      before do
        allow(crime_application).to receive(:valid?).with(:submission).and_return(false)
      end

      it 'fails to save' do
        expect(subject.save).to be false
      end
    end
  end
end
