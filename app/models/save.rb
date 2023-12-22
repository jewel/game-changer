class Save < ApplicationRecord
  belongs_to :version
  belongs_to :user
  # belongs_to :station
end
