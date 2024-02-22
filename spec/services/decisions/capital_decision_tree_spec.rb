require 'rails_helper'

RSpec.describe Decisions::CapitalDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, id: '10') }
  let(:form_object) { double('FormObject') }

  it_behaves_like 'a decision tree'

  context 'when the step is `saving_type`' do
    let(:step_name) { :saving_type }

    before do
      allow(form_object).to receive_messages(crime_application:, saving:)
    end

    context 'the client has no savings' do
      let(:saving) { nil }

      it 'redirects premium bonds' do
        expect(subject).to have_destination(:premium_bonds, :edit, id: crime_application)
      end
    end

    context 'the client has selected a saving type' do
      let(:saving) { 'new_saving' }

      it 'redirects the edit `savings` page' do
        expect(subject).to have_destination(:savings, :edit, id: crime_application, saving_id: saving)
      end
    end
  end

  context 'when the step is `savings`' do
    let(:step_name) { :savings }

    before do
      allow(form_object).to receive_messages(crime_application:)
    end

    context 'has correct next step' do
      it { is_expected.to have_destination(:savings_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `savings_summary`' do
    let(:step_name) { :savings_summary }
    let(:saving) { 'new_saving' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_saving:)
    end

    context 'the client has selected yes to adding a savings account' do
      let(:add_saving) { YesNoAnswer::YES }

      it 'redirects the edit `saving type` page' do
        expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected no to adding a savings account' do
      let(:add_saving) { YesNoAnswer::NO }

      it 'redirects the edit premium bonds page' do
        expect(subject).to have_destination(:premium_bonds, :edit, id: crime_application)
      end
    end
  end
end
