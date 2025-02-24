require 'rails_helper'

describe Summary::Sections::FundingDecisions do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      LaaCrimeSchemas::Structs::CrimeApplication,
      status:,
      decisions:,
    )
  end

  let(:status) { ApplicationStatus::SUBMITTED }

  let(:decisions) do
    [
      {
        reference: nil,
        maat_id: nil,
        interests_of_justice: {
          result: 'pass',
          details: 'Details',
          assessed_by: 'Grace Nolan',
          assessed_on: Date.new(2024, 10, 8)
        },
        means: nil,
        funding_decision: 'granted_on_ioj',
        comment: ''
      }
    ]
  end

  describe '#heading' do
    it { expect(subject.heading).to eq(:funding_decisions) }
  end

  describe '#show?' do
    it 'shows this section' do
      expect(subject.show?).to be(true)
    end

    context 'when the application is not submitted' do
      let(:status) { ApplicationStatus::IN_PROGRESS }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when there are no funding decisions' do
      let(:decisions) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:component) { instance_double(Summary::Components::FundingDecision) }

    before do
      allow(Summary::Components::FundingDecision).to receive(:with_collection) { component }
    end

    it 'returns the component without actions' do
      expect(subject.answers).to be component

      expect(Summary::Components::FundingDecision).to have_received(:with_collection).with(
        decisions, show_actions: false
      )
    end
  end

  describe '#list?' do
    it { expect(subject.list?).to be(true) }
  end
end
