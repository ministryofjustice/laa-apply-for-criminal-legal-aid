require 'rails_helper'

RSpec.describe Decisions::AddressDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `lookup`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lookup }

    it { is_expected.to have_destination(:results, :edit, id: crime_application) }
  end

  context 'when the step is `results`' do
    let(:form_object) { double('FormObject', record: address_record) }
    let(:step_name) { :results }

    context 'if we come from a home address sub-journey' do
      let(:address_record) { HomeAddress.new }

      it { is_expected.to have_destination('/steps/client/contact_details', :edit, id: crime_application) }
    end

    context 'if we come from a correspondence address sub-journey' do
      let(:address_record) { CorrespondenceAddress.new }

      before do
        allow(crime_application).to receive(:age_passported?).and_return(age_passported)
      end

      context 'and applicant is `age_passported`' do
        let(:age_passported) { true }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'and applicant is not `age_passported`' do
        let(:age_passported) { false }

        it { is_expected.to have_destination('steps/shared/nino', :edit, id: crime_application, subject: 'client') }
      end
    end

    context 'if we come from a partner details address journey' do
      let(:form_object) { double('FormObject', record: address_record) }
      let(:address_record) { HomeAddress.new(person: Partner.new) }

      before do
        allow(crime_application).to receive_messages(applicant:, partner:)
      end

      context 'when the applicant and partner have arc numbers' do
        let(:applicant) { instance_double(Applicant, arc: 'ABC12/345678/A') }
        let(:partner) { instance_double(Partner, arc: 'BCD12/345678/C') }

        it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
      end

      context 'when the applicant has an arc number' do
        let(:applicant) { instance_double(Applicant, arc: 'ABC12/345678/A') }
        let(:partner) { instance_double(Partner, arc: nil) }

        it { is_expected.to have_destination('/steps/dwp/partner_benefit_type', :edit, id: crime_application) }
      end

      context 'when neither the applicant or partner have arc numbers' do
        let(:applicant) { instance_double(Applicant, arc: nil) }
        let(:partner) { instance_double(Partner, arc: nil) }

        it { is_expected.to have_destination('/steps/dwp/benefit_type', :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    it 'runs the same logic as the `results` step' do
      expect(subject).to receive(:after_address_entered)
      subject.destination
    end
  end
end
