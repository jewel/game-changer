# A bucket is a collection of files.  The file contents will be stored in a
# content-addressable store.  The bucket can be serialized to the database as a
# JSON list, where each list item is an array of "path", "hash", "size",
# "mtime".

class Bucket
  def initialize json={}
    @files = {}

    json.each do |file|
      @files[file[:path]] = file
    end
  end

  def as_json
    @files.values
  end

  def self.from_json json
    Bucket.new json
  end

  def as_compact_json
    @files.map do |path, info|
      [path, info[:hash], info[:size], info[:mtime], info[:executable]]
    end
  end

  def self.from_compact_json json
    expanded = json.map do |(path, hash, size, mtime, executable)|
      {
        path: path,
        hash: hash,
        size: size,
        mtime: mtime,
        executable: executable,
      }
    end
    Bucket.new expanded
  end

  # Call add to write files to the bucket storage.  This is destructive!
  def add path, file
    hash = BucketFile.store file
    stat = file.stat

    @files[path] = {
      path: path,
      hash: hash,
      size: stat.size,
      mtime: stat.mtime.to_f,
      executable: stat.executable?,
    }
    hash
  end
end
