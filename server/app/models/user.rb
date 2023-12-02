class User < ApplicationRecord
  has_many :saved_games

  def icon= file
    self[:icon] = Base64.encode64 file.read
  end
end
