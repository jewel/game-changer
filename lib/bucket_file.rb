class BucketFile
  BASEURL = Pathname.new "/bucket"
  BASEDIR = Rails.root + "public#{BASEURL}"

  def self.storage hash
    # split into multiple directories for performance on bad filesystems
    BASEDIR + hash[0...2] + hash[0...4] + hash
  end

  def self.url hash
    BASEURL + hash[0...2] + hash[0...4] + hash
  end

  # Call add to write files to the bucket storage.  This is destructive!
  def self.store file
    hash = Digest::MD5.file(file).hexdigest
    dest = storage hash
    FileUtils.mkdir_p File.dirname dest
    FileUtils.cp file, dest
    hash
  end
end
