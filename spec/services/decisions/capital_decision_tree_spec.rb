require 'rails_helper'

RSpec.describe Decisions::CapitalDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'

  context 'when the step is `saving_type`' do
    let(:crime_application) { instance_double(CrimeApplication, id: '10') }
    let(:form_object) { double('FormObject') }
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
end
