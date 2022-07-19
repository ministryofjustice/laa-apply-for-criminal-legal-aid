ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder.configure do |config|
  config.default_legend_tag   = 'h1'
  config.default_legend_size  = 'xl'
  config.default_caption_size = 'xl'
end

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  require 'form_builder_helper'
  include FormBuilderHelper
end
