class Version < ApplicationRecord
  belongs_to :game

  after_commit :process_files
  after_commit :process_tar

  def storage_directory
    Rails.root + "public#{storage_url}"
  end

  def storage_url
    "/games/#{game.id}/#{id}"
  end

  def directory= files
    @incoming_files = files
    self.size = 0
    self.files = 0

    files.each do |file|
      next if file.blank?
      self.size += file.size
      self.files += 1
    end
  end

  def tar= tar
    @incoming_tar = tar
  end

  def content
    res = []
    storage_directory.find do |file|
      stat = file.stat
      next unless stat.file?
      path = file.relative_path_from storage_directory
      res.push({
        path: path,
        size: stat.size,
        mtime: stat.mtime.to_f,
        executable: stat.executable?,
        writable: stat.writable?,
      })
    end
    res
  end

  private
  def process_files
    return unless @incoming_files

    @incoming_files.each do |file|
      next if file.blank?
      file.headers =~ /filename="(.+?)"/ or raise "Cannot find filename"
      # FIXME sanitize input filename
      dest_path = "#{storage_directory}/#$1"
      FileUtils.mkdir_p File.dirname dest_path
      FileUtils.mv file.path, dest_path
    end

    @incoming_files = nil
  end

  def process_tar
    return unless @incoming_tar
    FileUtils.mkdir_p storage_directory
    system "tar xf #{se @incoming_tar.path} -C #{se storage_directory}"
    raise "Problem running tar" unless $? == 0
    @incoming_tar = nil

    count = 0
    bytes = 0

    storage_directory.find do |file|
      next unless file.file?
      count += 1
      bytes += file.size
    end

    self.files = count
    self.size = bytes
    self.save!
  end

  def se str
    Shellwords.shellescape str
  end
end
