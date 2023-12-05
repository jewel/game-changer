# A bucket is a collection of files.  The file contents will be stored in a
# content-addressable store.  The bucket can be serialized to the database as a
# JSON list, where each list item is an array of "path", "hash", "size",
# "mtime".

class Bucket
  def self.add file
    bucket = new
    return bucket.add "placeholder", file
  end

  BASEURL = Pathname.new "/bucket"
  BASEDIR = Rails.root + "public#{BASEURL}"

  def self.storage hash
    # split into multiple directories for performance on bad filesystems
    BASEDIR + hash[0...2] + hash[0...4] + hash
  end

  def storage hash
    self.class.storage hash
  end

  def self.url hash
    BASEURL + hash[0...2] + hash[0...4] + hash
  end

  def url hash
    self.class.url hash
  end

  def initialize json=nil
    @files = {}
    if json
      json.each do |(path, hash, size, mtime, executable)|
        files[path] = {
          path: path,
          hash: hash,
          size: size,
          mtime: mtime,
          executable: executable,
        }
      end
    end
  end

  def as_json
    @files.map do |path, info|
      [path, info[:hash], info[:size], info[:mtime], info[:executable]]
    end
  end

  # Call add to write files to the bucket storage.  This is destructive!
  def add path, file
    hash = Digest::MD5.file(file).hexdigest
    dest = storage hash
    FileUtils.mkdir_p File.dirname dest
    FileUtils.mv file, dest
    stat = File.stat dest

    @files[path] = {
      hash: hash,
      size: stat.size,
      mtime: stat.mtime.to_f,
      executable: stat.executable?,
    }
    hash
  end
end
