require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#govuk_formatted_date' do
    it 'returns a date in the correct formatt' do
      datetime = Time.zone.local(2022, 8, 16, 15, 30, 45)
      expect(helper.govuk_formatted_date(datetime)).to eq('16 August 2022')
    end
  end
  
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

    describe '#decorate' do
      before do
        stub_const('FooBar', Class.new)
        stub_const('FooBarDecorator', Class.new(BaseDecorator))
      end

      let(:foobar) { FooBar.new }

      context 'for a specific delegator class' do
        it 'instantiate the decorator with the passed object' do
          expect(FooBarDecorator).to receive(:new).with(foobar)
          helper.decorate(foobar, FooBarDecorator)
        end
      end

      context 'using the object to infer the delegator class' do
        it 'instantiate the decorator with the passed object inferring the class' do
          expect(FooBarDecorator).to receive(:new).with(foobar)
          helper.decorate(foobar)
        end
      end
    end
  end
end
