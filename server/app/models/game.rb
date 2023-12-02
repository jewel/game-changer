class Game < ApplicationRecord
  has_many :versions
  has_many :saved_games, through: :versions

  has_one :default_version, class_name: "Version", required: false

  def default_version
    if default_version_id
      Version.find default_version_id
    else
      versions.order(:created_at).last
    end
  end

  def icon= file
    self[:icon] = Base64.encode64 file.read
  end
end
