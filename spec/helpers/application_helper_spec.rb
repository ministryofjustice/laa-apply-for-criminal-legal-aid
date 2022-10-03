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

    it 'calls #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end
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
