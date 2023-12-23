class Storage < Eventful
  event :made_progress

  def initialize game, version, bucket, old_save
    @game = game
    @version = version
    @bucket = bucket
    @old_save = old_save
  end

  def game_path
    storage_path + "game"
  end

  def storage_path
    home = ENV['HOME']
    raise "$HOME environment variable must be set" if !home || home == ''
    Pathname.new "#{home}/.cache/game-changer/#{@version[:id]}"
  end

  def download
    # FIXME we should first count all the files we already have, and
    # queue up those we need, so that we can give them a progress bar of just
    # what we intend to download.
    @downloaded = 0
    @total_size = 0
    @bucket.each do |file|
      @total_size += file[:size]
    end

    uri = URI Server.server_url
    Net::HTTP.start uri.host, uri.port do |http|
      @bucket.each do |file|
        fetch http, file
      end
    end

    # Cleanup any extra cruft from a previous run
    allowed_paths = Set.new
    @bucket.each do |file|
      allowed_paths.add file[:path]
    end

    # FIXME We could double-check for a previous run's save games first before
    # wiping them here
    storage_path.find do |file|
      next unless file.file?
      path = file.relative_path_from storage_path
      next if allowed_paths.member? path.to_s
      puts "remove: #{path}"

      file.unlink
    end
  end

  def upload_save
    game_files = {}

    # Note that this is the original bucket here
    @version[:bucket].each do |file|
      game_files[file[:path]] = file
    end

    files = []
    total_size = 0

    old_save_by_path = {}
    if @old_save
      @old_save[:bucket].each do |file|
        old_save_by_path[file[:path]] = file
      end
    end

    uri = URI Server.server_url
    Net::HTTP.start uri.host, uri.port do |http|
      save_bucket = []
      storage_path.find do |file|
        next unless file.file?
        if file.to_s.start_with? "#{game_path}/"
          path = file.relative_path_from game_path
          # ignore game files unless they have changed
          if old = game_files[path.to_s]
            mtime = Time.at old[:mtime]
            stat = file.stat
            next if (stat.mtime - mtime).abs <= 0.1 && stat.size == old[:size]
            puts "game file changed: #{path}"
          end
        end

        path = file.relative_path_from storage_path

        # Now check if file hasn't changed from the last save, if it hasn't
        # then we don't need to upload it again, but we still need to include
        # it in the bucket
        hash = nil
        if old = old_save_by_path[path.to_s]
          mtime = Time.at old[:mtime]
          stat = file.stat
          if (stat.mtime - mtime).abs <= 0.1 && stat.size == old[:size]
            hash = old[:hash]
            puts "old save file not changed: #{path}"
          else
            puts "old save file changed: #{path}"
          end
        end

        if !hash
          puts "uploading: #{path}"
          req = Net::HTTP::Post.new "/bucket_files"
          form_data = [['file', file.open('rb')]]
          req.set_form form_data, 'multipart/form-data'
          res = http.request req
          if res.code != "200"
            pp res
            raise "Could not upload, error #{res.code}: #{path}"
          end
          obj = JSON.parse res.body, symbolize_names: true
          hash = obj[:hash]
          raise "Missing hash" unless hash
        end

        save_bucket.push({
          path: path,
          hash: hash,
          size: file.size,
          mtime: file.mtime.to_f,
          executable: file.stat.executable?,
        })
      end
      return save_bucket
    end
  end

  private

  def fetch http, file
    path = file[:path]
    dest = "#{storage_path}/#{path}"
    mtime = Time.at file[:mtime]

    if File.exist? dest
      stat = File.stat dest
      if (stat.mtime - mtime).abs <= 0.1 && stat.size == file[:size]
        puts "correct: #{path}"
        return
      end
      puts "incorrect: #{path}"
      File.unlink dest
    end

    url = Server.bucket_url file[:hash]
    puts "downloading: #{dest}"

    req = Net::HTTP::Get.new url
    http.request req do |res|
      if res.code != "200"
        raise "HTTP Failure code: #{res.code}"
      end
      FileUtils.mkdir_p File.dirname dest
      File.open dest, 'wb' do |io|
        last_update = Time.new
        res.read_body do |chunk|
          io.write chunk
          @downloaded += chunk.size
          if Time.new - last_update > 1.0 / 30
            trigger :made_progress, @downloaded.to_f / @total_size
            last_update = Time.new
          end
        end
      end
    end
    File.utime mtime, mtime, dest
    mode = 0666
    mode |= 0111 if file[:executable]
    File.chmod mode, dest

    stat = File.stat dest
    unless (stat.mtime - mtime).abs <= 0.1 && stat.size == file[:size]
      raise "Was not able to save #{dest} properly"
    end
  end
end
