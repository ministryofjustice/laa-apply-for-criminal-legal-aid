ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  require 'form_builder_helper'
  include FormBuilderHelper
end
