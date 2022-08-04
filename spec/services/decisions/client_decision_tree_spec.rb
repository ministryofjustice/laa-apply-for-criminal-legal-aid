require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'

  context 'when the step is `has_partner`' do
    let(:form_object) { double('FormObject', client_has_partner: client_has_partner) }
    let(:step_name) { :has_partner }

    context 'and answer is `no`' do
      let(:client_has_partner) { YesNoAnswer::NO }
      it { is_expected.to have_destination(:details, :edit) }
    end

    context 'and answer is `yes`' do
      let(:client_has_partner) { YesNoAnswer::YES }
      it { is_expected.to have_destination(:partner_exit, :show) }
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    it { is_expected.to have_destination(:has_nino, :edit) }
  end

  context 'when the step is `has_nino`' do
    let(:form_object) { double('FormObject', applicant: 'applicant', has_nino: has_nino) }
    let(:step_name) { :has_nino }

    context 'and answer is `no`' do
      let(:has_nino) { YesNoAnswer::NO }
      it { is_expected.to have_destination(:nino_exit, :show) }
    end

    context 'and answer is `yes`' do
      let(:has_nino) { YesNoAnswer::YES }

      before do
        allow(
          HomeAddress
        ).to receive(:find_or_create_by).with(person: 'applicant').and_return('address')
      end

      it { expect(subject.destination).to eq(controller: '/steps/address/lookup', action: :edit, id: 'address') }
    end
  end

  context 'when the step is `contact_details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :contact_details }

    it { is_expected.to have_destination('/home', :index) }
  end
end
