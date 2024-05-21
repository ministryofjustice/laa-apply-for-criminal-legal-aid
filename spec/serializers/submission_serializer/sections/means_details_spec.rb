require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::MeansDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, income:) }
  let(:income) { instance_double(Income) }
  let(:requires_means_assessment?) { true }

  before do
    allow(subject).to receive(:requires_means_assessment?)
      .and_return(requires_means_assessment?)
  end

  describe '#generate' do
    context 'when income present and means assessment not required' do
      let(:requires_means_assessment?) { false }
      let(:json_output) { {} }

      it { expect(subject.generate).to eq(json_output) }
    end

    context 'when income present and means assessment required' do
      let(:json_output) do
        {
          means_details: {
            income_details: 'INCOME',
            outgoings_details: 'OUTGOINGS',
            capital_details: 'CAPITAL',
          }
        }.as_json
      end

      before do
        allow(SubmissionSerializer::Sections::IncomeDetails).to receive(:new)
          .with(crime_application).and_return(double(to_builder: 'INCOME'))
        allow(SubmissionSerializer::Sections::OutgoingsDetails).to receive(:new)
          .with(crime_application).and_return(double(to_builder: 'OUTGOINGS'))
        allow(SubmissionSerializer::Sections::CapitalDetails).to receive(:new)
          .with(crime_application).and_return(double(to_builder: 'CAPITAL'))
      end

      it { expect(subject.generate).to eq(json_output) }
    end
  end
end
