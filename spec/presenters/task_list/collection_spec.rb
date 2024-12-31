require 'rails_helper'

RSpec.describe TaskList::Collection do
  subject(:collection) { described_class.new(crime_application:) }

  let(:name) { :foobar_task }
  let(:crime_application) { double application_type: 'initial' }

  describe '#sections' do
    subject(:sections) { collection.sections }

    it 'has the `client_details` section' do
      expect(sections[0].name).to eq(:about_your_client)
      expect(sections[0].tasks.map(&:name)).to eq([:client_details, :partner_details, :passporting_benefit_check])
    end

    it 'has the `case_details` section' do
      expect(sections[1].name).to eq(:case_details)
      expect(sections[1].tasks.map(&:name)).to eq([:case_details, :ioj])
    end

    it 'has the `means_assessment` section' do
      expect(sections[2].name).to eq(:means_assessment)
      expect(sections[2].tasks.map(&:name)).to eq([:income_assessment, :outgoings_assessment, :capital_assessment])
    end

    it 'has the `support_evidence` section' do
      expect(sections[3].name).to eq(:support_evidence)
      expect(sections[3].tasks.map(&:name)).to eq([:evidence_upload])
    end

    it 'has the `more_information` section' do
      expect(sections[4].name).to eq(:more_information)
      expect(sections[4].tasks.map(&:name)).to eq([:more_information])
    end

    it 'has the `review_confirm` section' do
      expect(sections[5].name).to eq(:review_confirm)
      expect(sections[5].tasks.map(&:name)).to eq([:review, :declaration])
    end
  end

  describe '#completed' do
    before do
      allow(Tasks::BaseTask).to receive(:build).and_return(task_completed, task_incomplete)
    end

    let(:task_completed) { double(status: double(completed?: true)) }
    let(:task_incomplete) { double(status: double(completed?: false)) }

    it 'returns only the completed tasks' do
      expect(subject.completed).to eq([task_completed])
    end
  end

  describe '#applicable' do
    let(:applicable_task) { double(status: double(not_applicable?: false)) }

    before do
      allow(Tasks::BaseTask).to receive(:build).and_return(
        applicable_task, double(status: double(not_applicable?: true))
      )
    end

    it 'returns only the applicable tasks' do
      expect(subject.applicable).to eq([applicable_task])
    end
  end
end
