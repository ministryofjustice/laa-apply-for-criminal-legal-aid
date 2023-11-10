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
      allow(helper).to receive_messages(controller_name: 'my_controller', action_name: 'an_action')

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'calls #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end
  end

  describe '#hours_or_minutes' do
    context 'when minutes can be represented as whole hours' do
      it { expect(helper.hours_or_minutes(60.minutes)).to eq('an hour') }
      it { expect(helper.hours_or_minutes(120.minutes)).to eq('2 hours') }
    end

    context 'when minutes do not fill whole hours' do
      it { expect(helper.hours_or_minutes(1.minute)).to eq('a minute') }
      it { expect(helper.hours_or_minutes(30.minutes)).to eq('30 minutes') }
      it { expect(helper.hours_or_minutes(125.minutes)).to eq('125 minutes') }
    end
  end

  describe '#present' do
    before do
      stub_const('FooBar', Class.new)
      stub_const('FooBarPresenter', Class.new(BasePresenter))
    end

    let(:foobar) { FooBar.new }

    context 'for a specific delegator class' do
      it 'instantiate the presenter with the passed object' do
        expect(FooBarPresenter).to receive(:new).with(foobar)
        helper.present(foobar, FooBarPresenter)
      end
    end

    context 'using the object to infer the delegator class' do
      it 'instantiate the presenter with the passed object inferring the class' do
        expect(FooBarPresenter).to receive(:new).with(foobar)
        helper.present(foobar)
      end
    end
  end
end
