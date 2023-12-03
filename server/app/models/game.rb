class Game < ApplicationRecord
  has_many :versions
  has_many :saved_games, through: :versions

  has_one :default_version, class_name: "Version", required: false

  after_commit :process_tar

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

  def upload_tar= file
    @tar = file
  end

  def version_number
    ""
  end

  def version_number= number
    @version_number = number
  end


  private
  def process_tar
    return unless @tar
    versions.create!({
      number: @version_number,
      tar: @tar,
      files: 0,
      size: 0,
    })
  end
end
