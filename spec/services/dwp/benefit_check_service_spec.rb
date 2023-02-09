require 'rails_helper'
require 'savon/mock/spec_helper'

RSpec.describe DWP::BenefitCheckService do
  subject { described_class }

  let(:last_name) { 'Walker' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:nino) { 'JA293483A' }
  let(:id) { '123' }

  let(:applicant) do
    double(
      Applicant,
      id:,
      last_name:,
      date_of_birth:,
      nino:,
    )
  end

  let(:use_mock) { false }

  before do
    allow(Rails.configuration.x.benefit_checker)
      .to receive(:use_mock)
      .and_return(use_mock)
  end

  describe '.call' do
    before do
      stub_request(:post, 'http://benefit-checker/?wsdl')
        .to_return(body: benefit_checker_fixture)
    end

    let(:expected_params) do
      hash_including(
        message: hash_including(
          clientReference: applicant.id,
          surname: applicant.last_name.strip.upcase,
          dateOfBirth: applicant.date_of_birth.strftime('%Y%m%d'),
        ),
      )
    end

    let(:benefit_checker_fixture) { file_fixture('benefit_checker_responses/successful.xml').read }

    context 'when the call is successful' do
      it 'returns the right parameters' do
        result = subject.new(applicant).call
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:original_client_ref]).not_to be_empty
        expect(result[:confirmation_ref]).not_to be_empty
      end

      it 'sends the right parameters' do
        expect_any_instance_of(Savon::Client)
          .to receive(:call)
          .with(:check, expected_params)
          .and_call_original

        subject.call(applicant)
      end

      context 'when the last name is not in upper case' do
        let(:last_name) { ' walker ' }

        it 'normalizes the last name' do
          result = subject.call(applicant)
          expect(result[:benefit_checker_status]).to eq('Yes')
        end

        it 'sends the right parameters' do
          expect_any_instance_of(Savon::Client)
            .to receive(:call)
            .with(:check, expected_params)
            .and_call_original

          subject.call(applicant)
        end
      end
    end

    context 'calling API fails' do
      context 'and raises a standard error' do
        before do
          allow_any_instance_of(Savon::Client)
            .to receive(:call)
            .with(:check, expected_params)
            .and_raise(exception)
        end

        let(:exception) { StandardError.new('boom!') }

        it 'captures error' do
          expect(Sentry).to receive(:capture_exception).with(exception)
          subject.passporting_benefit?(applicant)
        end

        it 'returns nil' do
          expect(subject.passporting_benefit?(applicant)).to be_nil
        end
      end
    end
  end

  describe '.passporting_benefit?' do
    describe 'behaviour without mock' do
      before do
        allow_any_instance_of(described_class).to receive(:call).and_return({ benefit_checker_status: 'Yes' })
      end

      it 'calls an instance call method' do
        expect(subject.passporting_benefit?(applicant)).to be(true)
      end
    end

    describe 'behaviour with mock' do
      let(:use_mock) { true }

      it 'returns the right parameters' do
        expect(subject.passporting_benefit?(applicant)).to be(true)
      end

      context 'with matching data' do
        let(:last_name) { 'Smith' }
        let(:date_of_birth) { '1999/01/11'.to_date }
        let(:nino) { 'NC123459A' }

        it 'returns true' do
          expect(subject.passporting_benefit?(applicant)).to be(true)
        end
      end
    end
  end
end
