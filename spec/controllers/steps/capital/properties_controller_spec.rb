require 'rails_helper'

RSpec.describe Steps::Capital::PropertiesController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::PropertyTypeForm,
                  Decisions::CapitalDecisionTree
end
