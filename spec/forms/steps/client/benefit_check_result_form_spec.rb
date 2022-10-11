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

  describe '#save' do
    it 'is expected to return true' do
      expect(subject.save).to be(true)
    end
  end
end
