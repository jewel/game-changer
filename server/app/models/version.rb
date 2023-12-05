class Version < ApplicationRecord
  belongs_to :game

  def directory= files
    bucket = Bucket.new
    bytes = 0

    files.each do |file|
      next if file.blank?
      # We have to pull the full filename from the headers because rails assumes
      # we don't care about the full path.
      file.headers =~ /filename="(.+?)"/ or raise "Cannot find filename"
      path = $1
      bytes += file.size
      bucket.add path, file.path
    end

    self.size = size
    self.bucket = bucket.as_json
  end

  def tar= tar
    bucket = Bucket.new
    bytes = 0

    Dir.mktmpdir "turbo-untar-" do |temp|
      system "tar xf #{se tar.path} -C #{se temp}"
      raise "Problem running tar" unless $? == 0

      Pathname.new(temp).find do |file|
        next unless file.file?
        path = file.relative_path_from temp
        bytes += file.size
        bucket.add path, file
      end
    end
    self.size = bytes
    self.bucket = bucket.as_json
  end

  private

  def se str
    Shellwords.shellescape str
  end
end
