module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      include Steps::Capital::PropertyUpdateStep
    end
  end
end
