require 'rails_helper'

RSpec.describe Steps::Client::BenefitCheckResultForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
    }
  end

  let(:last_name) { 'Smith' }
  let(:date_of_birth) { '1999/01/11'.to_date }
  let(:nino) { 'NC123459A' }
  let(:crime_application) do
    instance_double(CrimeApplication,
                    applicant:)
  end

  let(:applicant) do
    double(
      Applicant,
      last_name:,
      date_of_birth:,
      nino:
    )
  end

  describe '#benefit_check_result' do
    context 'for a known national insurance number' do
      it 'is expected to return the correct result' do
        expect(subject.benefit_check_result).to eql({ benefit_checker_status: 'Yes',
  confirmation_ref: 'mocked:MockBenefitCheckService' })
      end
    end

    context 'for an unknown national insurance number' do
      let(:nino) { 'AB123456C' }

      it 'is expected to return the correct result' do
        expect(subject.benefit_check_result).to eql({ benefit_checker_status: 'No',
  confirmation_ref: 'mocked:MockBenefitCheckService' })
      end
    end
  end

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'for a client with a passporting benefit' do
      it 'is updates the record' do
        expect(applicant).to receive(:update).with(
          passporting_benefit: 'Yes'
        ).and_return(true)

        expect(subject.save).to be(true)
      end

      context 'when `confirm_benefit_check_result` is not provided' do
        it 'does not have a validation error on the field' do
          expect(subject).to be_valid
          expect(subject.errors.of_kind?(:confirm_benefit_check_result, :inclusion)).to be(false)
        end
      end

      context 'for a client without a passporting benefit' do
        let(:nino) { 'NC123459B' }

        context 'when `confirm_benefit_check_result` is not provided' do
          before do
            allow(subject).to receive(:confirm_benefit_check_result)
              .and_return(nil)
          end

          it 'returns false' do
            expect(subject.save).to be(false)
          end

          it 'has a validation error on the field' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:confirm_benefit_check_result, :inclusion)).to be(true)
          end
        end

        context 'where the caseworker confirms the result' do
          before do
            allow(subject).to receive(:confirm_benefit_check_result)
              .and_return('Yes')
          end

          it 'updates the record' do
            expect(applicant).to receive(:update).with(
              passporting_benefit: 'No'
            ).and_return(true)

            expect(subject.save).to be(true)
          end
        end

        context 'where the caseworker does not confirm the result' do
          before do
            allow(subject).to receive(:confirm_benefit_check_result)
              .and_return('No')
          end

          it 'updates the record' do
            expect(applicant).to receive(:update).with(
              passporting_benefit: nil
            ).and_return(true)

            expect(subject.save).to be(true)
          end
        end
      end
    end
  end
end
