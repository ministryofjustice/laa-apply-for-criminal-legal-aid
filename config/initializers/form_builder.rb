ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  require 'form_builder_helper'
  include FormBuilderHelper
end

GOVUKDesignSystemFormBuilder.configure do |conf|
  conf.default_collection_radio_buttons_include_hidden = false
end
