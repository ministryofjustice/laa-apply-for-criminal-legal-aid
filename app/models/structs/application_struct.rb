module Structs
  class ApplicationStruct < Dry::Struct
    # convert string keys to symbols
    transform_keys(&:to_sym)
  end
end
