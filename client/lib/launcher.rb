require_relative 'bucket'
require_relative 'storage'

class Launcher < Eventful
  event :status_changed
  event :game_exited
  event :progress

  def initialize game, user
    @game = game
    @user = user
  end

  def spawn
    @thread = Thread.new do
      prepare
      download
      start
    end
  end

  def kill
    @thread.kill
  end

  private

  def prepare
    @version = @game[:default_version]
    # Load more data
    @version = Server.get "/versions/#{@version[:id]}"

    bucket = Bucket.new @version[:bucket]
    bucket.adjust_path! do |path|
      "game/#{path}"
    end

    @save = Server.get "/saves/latest?user_id=#{@user[:id]}&game_id=#{@game[:id]}"

    # Saved files may overlap the original game files, (e.g. a preferences file)
    if @save
      save_bucket = Bucket.new @save[:bucket]
      bucket.merge! save_bucket
    end

    @storage = Storage.new @game, @version, bucket, @save
  end

  def download
    @storage.download
  end

  def start
    # TODO use a PTY here to capture stdout and stderr
    if @version[:command] && @version[:command] != ""
      command = @version[:command]
    else
      raise "No command"
    end

    # TODO use pgroup so we can watch all children
    env = clean_environment
    pid = Process.spawn env, "#{command}", chdir: game_path, unsetenv_others: true
    trigger :status_changed, "Running #{@game[:name]}"
    Process.wait pid
    trigger :status_changed, "Uploading saved games from #{@game[:name]}"

    save_bucket = @storage.upload_save

    uri = URI Server.server_url
    Net::HTTP.start uri.host, uri.port do |http|
      req = Net::HTTP::Post.new "/saves?user_id=#{@user[:id]}&version_id=#{@version[:id]}"
      req.add_field "Content-Type", "application/json"
      req.body = save_bucket.to_json
      res = http.request req
      if res.code != "200"
        pp res
        raise "Could not upload bucket, error #{res.code}"
      end
    end
  ensure
    trigger :game_exited
  end

  def game_path
    @storage.game_path.to_s
  end

  def clean_environment
    {
      'SHELL' => "/bin/bash",
      'PWD' => game_path,
      'LANG' => ENV['LANG'],
      'DISPLAY' => ENV['DISPLAY'],
      'XAUTHORITY' => ENV['XAUTHORITY'],
      'HOME' => @storage.storage_path.to_s,
      'USER' => "ggttyl",
      'USERNAME' => "ggttyl",
      'PATH' => "#{game_path}:#{ENV['PATH']}",
    }
  end
end
