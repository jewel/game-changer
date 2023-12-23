class Bucket
  attr_accessor :files

  def initialize files
    @files = files.dup
  end

  def merge! other
    files = @files + other.files

    # remove duplicates, last one wins
    paths = Set.new
    files.reverse!
    files.select! do |file|
      present = paths.member? file[:path]
      paths.add file[:path]
      !present
    end
    files.reverse!
    @files = files
  end

  def adjust_path!
    @files.map! do |file|
      res = file.dup
      res[:path] = yield file[:path]
      res
    end
  end

  def each &block
    @files.each &block
  end
end
