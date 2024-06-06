require 'rails_helper'

RSpec.describe SectionsCompletenessValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:) }
  let(:errors) { double(:errors, empty?: false) }

  describe '#validate' do
    before { allow(record).to receive_messages(**attributes) }

    context 'when means assessment not required' do
      before do
        allow(subject).to receive(:requires_means_assessment?).and_return(false)
      end

      context 'when case complete' do
        let(:errors) { [] }

        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            partner_detail: double(complete?: true),
          }
        end

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
    end

    context 'when partial means assessment required' do
      before do
        allow(subject).to receive_messages(requires_means_assessment?: true, requires_full_means_assessment?: false)
      end

      let(:errors) { [] }

      let(:attributes) do
        {
          client_details_complete?: true,
          passporting_benefit_complete?: true,
          kase: double(complete?: true),
          income: double(complete?: true),
          partner_detail: double(complete?: true),
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
        let(:errors) { [] }

        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            income: double(complete?: true),
            outgoings: double(complete?: true),
            capital: double(complete?: true),
            partner_detail: double(complete?: true),
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
            partner_detail: double(complete?: false),
          }
        end

        it 'adds errors to all sections and base' do
          expect(errors).to receive(:add).with(:benefit_type, :incomplete)
          expect(errors).to receive(:add).with(:case_details, :incomplete)
          expect(errors).to receive(:add).with(:income_assessment, :incomplete)
          expect(errors).to receive(:add).with(:outgoings_assessment, :incomplete)
          expect(errors).to receive(:add).with(:capital_assessment, :incomplete)
          expect(errors).to receive(:add).with(:partner_details, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end

      context 'when income, outgoings, capital and partner details are missing' do
        let(:attributes) do
          {
            client_details_complete?: true,
            passporting_benefit_complete?: true,
            kase: double(complete?: true),
            income: nil,
            outgoings: nil,
            capital: nil,
            partner_detail: nil,
          }
        end

        it 'adds errors to all sections and base' do
          expect(errors).to receive(:add).with(:income_assessment, :incomplete)
          expect(errors).to receive(:add).with(:outgoings_assessment, :incomplete)
          expect(errors).to receive(:add).with(:capital_assessment, :incomplete)
          expect(errors).to receive(:add).with(:partner_details, :incomplete)
          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end
    end
  end
end
