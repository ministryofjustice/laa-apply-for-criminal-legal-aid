require 'rails_helper'

RSpec.describe Decisions::CaseDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  it_behaves_like 'a decision tree'

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  context 'when the step is `urn`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :urn }

    context 'has correct next step' do
      let(:case) { '12AA3456789' }

      it { is_expected.to have_destination('/steps/case/case_type', :edit, id: crime_application) }
    end
  end

  context 'when the step is `case_type`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :case_type }

    context 'has correct next step' do
      let(:case) { '12AA3456789' }

      it { is_expected.to have_destination('/steps/case/has_codefendants', :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_codefendants`' do
    let(:form_object) { double('FormObject', has_codefendants: has_codefendants) }
    let(:step_name) { :has_codefendants }

    context 'and answer is `no`' do
      let(:has_codefendants) { YesNoAnswer::NO }
      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end

    context 'and answer is `yes`' do
      let(:has_codefendants) { YesNoAnswer::YES }
      it { is_expected.to have_destination(:codefendants, :edit, id: crime_application) }
    end
  end

  context 'when the step is `add_codefendant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :add_codefendant }

    it 'creates a blank co-defendant record and gets back to the codefendants page' do
      expect(
        form_object
      ).to receive(:add_blank_codefendant).at_least(:once)

      is_expected.to have_destination(:codefendants, :edit, id: crime_application)
    end
  end

  context 'when the step is `delete_codefendant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :delete_codefendant }

    it 'gets back to the codefendants page' do
      is_expected.to have_destination(:codefendants, :edit, id: crime_application)
    end
  end

  context 'when the step is `codefendants_finished`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :codefendants_finished }

    it { is_expected.to have_destination('/home', :index, id: crime_application) }
  end
end
