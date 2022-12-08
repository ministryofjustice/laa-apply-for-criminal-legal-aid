class Provider
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :first_name, :string
  attribute :last_name, :string

  attribute :roles, array: true, default: -> { [] }
  attribute :office_codes, array: true, default: -> { [] }
end
