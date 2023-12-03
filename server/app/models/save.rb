class Save < ApplicationRecord
  belongs_to :version
  belongs_to :user
  # belongs_to :station

  def storage_path
    Rails.root + "public#{storage_url}"
  end

  def storage_url
    "/saves/#{user.id}/#{version.game.id}/#{id}"
  end

  def write_to_disk io
    FileUtils.mkdir_p storage_path.dirname
    f = storage_path.open 'wb'
    IO.copy_stream io, f
  end

  def read_from_disk
    storage_path.open 'rb'
  end
end
