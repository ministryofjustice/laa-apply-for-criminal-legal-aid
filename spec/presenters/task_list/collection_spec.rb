require 'rails_helper'

RSpec.describe TaskList::Collection do
  include ActionView::TestCase::Behavior

  subject { described_class.new(view, crime_application:) }

  let(:name) { :foobar_task }
  let(:crime_application) { double application_type: 'initial' }

  describe 'collection of sections' do
    it 'has the `client_details` section' do
      expect(subject[0].index).to eq(1)
      expect(subject[0].name).to eq(:about_your_client)
      expect(subject[0].tasks).to eq([:client_details, :partner_details, :passporting_benefit_check])
    end

    it 'has the `case_details` section' do
      expect(subject[1].index).to eq(2)
      expect(subject[1].name).to eq(:case_details)
      expect(subject[1].tasks).to eq([:case_details, :ioj])
    end

    it 'has the `means_assessment` section' do
      expect(subject[2].index).to eq(3)
      expect(subject[2].name).to eq(:means_assessment)
      expect(subject[2].tasks).to eq([:income_assessment, :outgoings_assessment, :capital_assessment])
    end

    it 'has the `support_evidence` section' do
      expect(subject[3].index).to eq(4)
      expect(subject[3].name).to eq(:support_evidence)
      expect(subject[3].tasks).to eq([:evidence_upload])
    end

    it 'has the `more_information` section' do
      expect(subject[4].index).to eq(5)
      expect(subject[4].name).to eq(:more_information)
      expect(subject[4].tasks).to eq([:more_information])
    end

    it 'has the `review_confirm` section' do
      expect(subject[5].index).to eq(6)
      expect(subject[5].name).to eq(:review_confirm)
      expect(subject[5].tasks).to eq([:review, :declaration])
    end
  end

  describe '#completed' do
    before do
      allow(TaskList::Task).to receive(:new).and_return(task_completed, task_incomplete)
    end

    let(:task_completed) { double(completed?: true) }
    let(:task_incomplete) { double(completed?: false) }

    it 'returns only the completed tasks' do
      expect(subject.completed).to eq([task_completed])
    end
  end

  describe '#applicable' do
    let(:applicable_task) { double(not_applicable?: false) }

    before do
      allow(TaskList::Task).to receive(:new).and_return(
        applicable_task, double(not_applicable?: true)
      )
    end

    it 'returns only the applicable tasks' do
      expect(subject.applicable).to eq([applicable_task])
    end
  end

  describe '#render' do
    before do
      # We test the Section separately, here we don't need to
      allow_any_instance_of(TaskList::Section).to receive(:render).and_return('[section_markup]')
    end

    it 'iterates through the sections defined, rendering each one' do
      expect(
        TaskList::Section
      ).to receive(:new).exactly(6).times.and_return(double.as_null_object)

      expect(
        subject.render
      ).to match(%r{<ol class="moj-task-list">.*</ol>})
    end
  end
end
