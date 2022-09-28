require 'rails_helper'

RSpec.describe DateStamp do
    subject(:service) { described_class.new(form_object) }

    let(:form_object) { double('form_object') }
    let(:crime_application) { double('crime_application') }

    before do
      allow(:form_object).receive(crime_application).and_return(crime_application)
      allow(:form_object).receive(case_type).and_return(case_type)
    end
    
    describe '.call' do
      context 'when case_type is date_stampable and currently nil' do
        let(:case_type) { double('case_type') }

      end

      context 'when case_type is not date_stampable' do
        let(:case_type) { double('case_type') }

      end

      context 'when case_type is date_stampable and already date_stamped' do
        let(:case_type) { double('case_type') }

      end
    end
end