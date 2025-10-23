require 'rails_helper'

RSpec.describe Providers::SchedulesToOfficeTranslator do
  describe '#translate' do
    subject(:translate) { described_class.new(office_schedules:).translate }

    let(:office_schedules) {
      ProviderDataApi::OfficeSchedules.new(
        JSON.parse(office_schedules_json)
      )
    }

    describe 'a Public Defenders Service Office' do
      let(:office_schedules_json) do
        file_fixture('provider_data_api/public_defender_service.json').read
      end

      it 'returns an Office with correct attributes' do
        expect(translate.office_code).to eq('2N990V')
        expect(translate.name).to eq('2N990V,THE GATEHOUSE')
        expect(translate.active?).to be true
        expect(translate.contingent_liability?).to be false
      end
    end

    describe 'a Contingent Liability Office' do
      let(:office_schedules_json) do
        file_fixture('provider_data_api/contingent_liability.json').read
      end

      it 'returns an Office with correct attributes' do
        expect(translate.office_code).to eq('0P803Q')
        expect(translate.name).to eq('0P803Q,TOP FLOOR, TREE HOUSE')
        expect(translate.active?).to be true
        expect(translate.contingent_liability?).to be true
      end
    end

    describe 'a Prison only office' do
      let(:office_schedules_json) do
        file_fixture('provider_data_api/prison_only.json').read
      end

      it 'returns an Office with correct attributes' do
        expect(translate.office_code).to eq('0P803Q')
        expect(translate.name).to eq('0P803Q,TOP FLOOR, TREE HOUSE')
        expect(translate.active?).to be false
        expect(translate.contingent_liability?).to be false
      end
    end

    describe 'an office with overlapping schedules' do
      let(:office_schedules_json) do
        file_fixture('provider_data_api/overlapping_schedules.json').read
      end

      it 'returns an Office with correct attributes' do
        expect(translate.office_code).to eq('XXXXXX')
        expect(translate.name).to eq('XXXXXX,OVERLAPPING STREET')
        expect(translate.active?).to be true
        # we take the highest privileged schedule when there is a conflict
        expect(translate.contingent_liability?).to be false
      end
    end

    describe 'an office with overlapping CL and active schedules' do
      let(:office_schedules_json) do
        file_fixture('provider_data_api/contingent_and_active_schedules.json').read
      end

      it 'returns an Office with correct attributes' do
        expect(translate.office_code).to eq('YYYYYY')
        expect(translate.name).to eq('YYYYYY,SUITE 99')
        expect(translate.active?).to be true
        # we take the highest privileged schedule when there is a conflict
        expect(translate.contingent_liability?).to be false
      end
    end
  end
end
