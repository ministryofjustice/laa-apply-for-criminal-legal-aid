require 'rails_helper'

RSpec.describe TaskList::Collection do
  include ActionView::TestCase::Behavior

  subject { described_class.new(view, crime_application:) }

  let(:name) { :foobar_task }
  let(:crime_application) { double }

  describe 'collection of sections' do
    it 'has the `client_details` section' do
      expect(subject[0].index).to eq(1)
      expect(subject[0].name).to eq(:client_details)
      expect(subject[0].tasks).to eq([:client_details])
    end

    it 'has the `case_details` section' do
      expect(subject[1].index).to eq(2)
      expect(subject[1].name).to eq(:case_details)
      expect(subject[1].tasks).to eq([:case_details, :ioj])
    end

    it 'has the `means_assessment` section' do
      expect(subject[2].index).to eq(3)
      expect(subject[2].name).to eq(:means_assessment)
      expect(subject[2].tasks).to eq([:income_assessment, :capital_assessment, :check_your_answers,
                                      :check_assessment_result])
    end

    it 'has the `support_evidence` section' do
      expect(subject[3].index).to eq(4)
      expect(subject[3].name).to eq(:support_evidence)
      expect(subject[3].tasks).to eq([:evidence_upload])
    end

    it 'has the `review_confirm` section' do
      expect(subject[4].index).to eq(5)
      expect(subject[4].name).to eq(:review_confirm)
      expect(subject[4].tasks).to eq([:application_review, :application_submission])
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

  describe '#render' do
    before do
      # We test the Section separately, here we don't need to
      allow_any_instance_of(TaskList::Section).to receive(:render).and_return('[section_markup]')
    end

    it 'iterates through the sections defined, rendering each one' do
      expect(
        TaskList::Section
      ).to receive(:new).exactly(5).times.and_return(double.as_null_object)

      expect(
        subject.render
      ).to match(%r{<ol class="app-task-list">.*</ol>})
    end
  end
end
