class GameSerializer < ActiveModel::Serializer
  attributes :id, :name, :icon

  has_one :default_version
end
