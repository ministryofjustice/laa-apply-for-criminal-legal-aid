require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmResultForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }

  describe '#save' do
    context 'when form is saved' do
      it 'resets necessary applicant attributes' do
        expect(applicant).to receive(:update).with({
                                                     'benefit_type' => BenefitType::NONE,
                                                     'has_benefit_evidence' => nil,
                                                     'confirm_details' => nil
                                                   }).and_return(true)
        expect(subject.save).to be(true)
      end
    end
  end
end
