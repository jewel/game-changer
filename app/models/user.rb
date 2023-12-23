class User < ApplicationRecord
  has_many :saves

  def icon= file
    self[:icon] = BucketFile.store file
  end
end
