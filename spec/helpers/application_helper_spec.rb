require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }
      it { expect(title).to eq('Apply for criminal legal aid - GOV.UK') }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }
      it { expect(title).to eq('Test page - Apply for criminal legal aid - GOV.UK') }
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive(:controller_name).and_return('my_controller')
      allow(helper).to receive(:action_name).and_return('an_action')

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'should call #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end
  end
end
