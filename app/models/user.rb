class User < ApplicationRecord
  has_many :saves

  def icon= file
    self[:icon] = Bucket.add file
  end
end
