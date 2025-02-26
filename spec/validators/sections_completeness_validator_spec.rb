require 'rails_helper'

RSpec.describe SectionsCompletenessValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors: errors, non_means_tested?: false) }
  let(:valid_attributes) do
    {
      client_details_complete?: true,
      passporting_benefit_complete?: true,
      kase: double(complete?: true),
      partner_detail: double(has_partner: 'no'),
      appeal_no_changes?: false,
      age_passported?: false
    }
  end
  let(:errors) { double(:errors, empty?: false) }
  let(:evidence_complete?) { false }
  let(:applicable?) { true }

  before do
    allow_any_instance_of(SupportingEvidence::AnswersValidator)
      .to receive(:evidence_complete?).and_return(evidence_complete?)
    allow_any_instance_of(SupportingEvidence::AnswersValidator)
      .to receive(:applicable?).and_return(applicable?)
    allow(InterestsOfJustice::AnswersValidator).to receive(:new).and_return(
      instance_double(InterestsOfJustice::AnswersValidator, applicable?: false)
    )
  end

  describe '#validate' do
    before { allow(record).to receive_messages(**attributes) }

    context 'when means assessment not required' do
      let(:evidence_complete?) { true }

      before do
        allow(subject).to receive(:requires_means_assessment?).and_return(false)
      end

      context 'when case complete' do
        let(:errors) { [] }

        let(:attributes) { valid_attributes }

        it 'does not add any errors' do
          subject.validate
        end
      end

      context 'when case incomplete' do
        let(:attributes) do
          { client_details_complete?: false }
        end

        it 'adds errors to case details' do
          expect(errors).to receive(:add).with(:client_details, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      describe 'when Interests of Justice applicable' do
        let(:attributes) { valid_attributes }

        before do
          allow(InterestsOfJustice::AnswersValidator).to receive(:new).and_return(
            instance_double(InterestsOfJustice::AnswersValidator, applicable?: true, complete?: ioj_complete?)
          )
        end

        context 'when IoJ complete' do
          let(:errors) { [] }
          let(:ioj_complete?) { true }

          it 'does not add any errors' do
            subject.validate
          end
        end

        context 'when IoJ incomplete' do
          let(:ioj_complete?) { false }

          it 'adds errors to Interests of Justice' do
            expect(errors).to receive(:add).with(:interests_of_justice, :incomplete)
            expect(errors).to receive(:add).with(:base, :incomplete_records)

            subject.validate
          end
        end
      end

      context 'when Interests of Justice incomplete' do
        let(:attributes) { valid_attributes }
        let(:evidence_complete?) { true }

        before do
          allow(InterestsOfJustice::AnswersValidator).to receive(:new).and_return(
            instance_double(InterestsOfJustice::AnswersValidator, applicable?: true, complete?: false)
          )
        end

        it 'adds errors to Interests of Justice' do
          expect(errors).to receive(:add).with(:interests_of_justice, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end
    end

    context 'when partial means assessment required' do
      before do
        allow(subject).to receive_messages(requires_means_assessment?: true, requires_full_means_assessment?: false)
      end

      let(:errors) { [] }
      let(:evidence_complete?) { true }

      let(:attributes) do
        {
          client_details_complete?: true,
          passporting_benefit_complete?: true,
          kase: double(complete?: true),
          income: double(complete?: true),
          partner_detail: double(has_partner: 'no'),
          appeal_no_changes?: false,
          age_passported?: false
        }
      end

      it 'does not add any errors' do
        subject.validate
      end
    end

    context 'when a full means assessment required' do
      before do
        allow(subject).to receive_messages(requires_means_assessment?: true, requires_full_means_assessment?: true)
      end

      context 'when all sections complete' do
        let(:evidence_complete?) { true }
        let(:errors) { [] }

        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            income: double(complete?: true),
            outgoings: double(complete?: true),
            capital: double(complete?: true),
            partner_detail: double(has_partner: 'no'),
            appeal_no_changes?: false,
            age_passported?: false
          }
        end

        it 'does not add any errors' do
          subject.validate
        end
      end

      context 'when passporting benefit, case, income, outgoings, capital and partner details incomplete' do
        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: false,
            kase: double(complete?: false),
            income: double(complete?: false),
            outgoings: double(complete?: false),
            capital: double(complete?: false),
            partner_detail: PartnerDetail.new(has_partner: 'yes'),
            partner: nil,
            appeal_no_changes?: false,
            age_passported?: false
          }
        end

        it 'adds errors to all sections and base' do # rubocop:disable RSpec/MultipleExpectations
          expect(errors).to receive(:add).with(:benefit_type, :incomplete)
          expect(errors).to receive(:add).with(:case_details, :incomplete)
          expect(errors).to receive(:add).with(:income_assessment, :incomplete)
          expect(errors).to receive(:add).with(:outgoings_assessment, :incomplete)
          expect(errors).to receive(:add).with(:capital_assessment, :incomplete)
          expect(errors).to receive(:add).with(:partner_details, :incomplete)
          expect(errors).to receive(:add).with(:documents, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when extent of means assessment is not yet known' do
        before do
          allow(subject).to receive(:requires_means_assessment?).and_return(true)
          allow(subject).to receive(:requires_full_means_assessment?).and_raise(
            Errors::CannotYetDetermineFullMeans
          )
        end

        let(:evidence_complete?) { true }
        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            income: double(complete?: true),
            outgoings: double(complete?: true),
            capital: double(complete?: true),
            partner_detail: nil,
            appeal_no_changes?: false,
            age_passported?: false
          }
        end

        it 'adds errors to outgoings, capital, base' do
          expect(errors).to receive(:add).with(:outgoings_assessment, :incomplete)
          expect(errors).to receive(:add).with(:capital_assessment, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when income, outgoings, capital and partner details are missing' do
        let(:evidence_complete?) { true }

        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            income: nil,
            outgoings: nil,
            capital: nil,
            partner_detail: PartnerDetail.new,
            partner: Partner.new,
            appeal_no_changes?: appeal_no_changes,
            age_passported?: age_passported?
          }
        end

        let(:age_passported?) { false }
        let(:appeal_no_changes) { false }

        it 'adds errors to all sections and base' do
          expect(errors).to receive(:add).with(:income_assessment, :incomplete)
          expect(errors).to receive(:add).with(:outgoings_assessment, :incomplete)
          expect(errors).to receive(:add).with(:capital_assessment, :incomplete)
          expect(errors).to receive(:add).with(:partner_details, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end

        context 'when applicant is under 18' do
          let(:age_passported?) { true }

          it 'does not add an error for the partner details section' do
            expect(errors).not_to receive(:add).with(:partner_details, :incomplete)

            subject.validate
          end
        end

        context 'when application is appeal no changes' do
          let(:appeal_no_changes) { true }

          it 'does not add an error for the partner details section' do
            expect(errors).not_to receive(:add).with(:partner_details, :incomplete)

            subject.validate
          end
        end
      end
    end
  end
end
