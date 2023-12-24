require_relative 'eventful'
require_relative 'login_screen'
require_relative 'server'
require_relative 'main_thread'
require_relative 'games_screen'
require_relative 'status_bar'
require_relative 'password_screen'
require_relative 'styles'
require_relative 'launcher'

class App
  def initialize
    @app = Gtk::Application.new 'com.tuxng.turbo', :flags_none

    @app.signal_connect('activate') { on_activate _1 }
  end

  def run
    @app.run
  end

  # Override because it's otherwise huge in exception messages
  def inspect
    "#<App>"
  end

  private

  def on_activate app
    @window = Gtk::ApplicationWindow.new app
    @window.set_title 'Game Changer'
    @window.set_default_size 800, 600

    Thread.new do
      fetch_users
      fetch_games
      main_thread :show_login_screen
    end
    show_spinner
  end

  def switch_contents content
    @window.remove @content if @content
    @content = content
    @window.add @content
    @window.show_all
  end

  def show_spinner
    box = Gtk::Box.new :vertical, 5
    box.set_valign Gtk::Align::CENTER
    spinner = Gtk::Spinner.new
    spinner.set_size_request 64, 64
    spinner.start
    box.add spinner

    switch_contents box
  end

  def fetch_users
    @users = Server.get "/users"
  end

  def show_login_screen
    screen = LoginScreen.new @users
    screen.user_chosen do |user|
      show_password_screen user
    end

    switch_contents screen.widget
  end

  def show_password_screen user
    screen = PasswordScreen.new user
    screen.cancelled do
      show_login_screen
    end

    screen.logged_in do |user|
      @current_user = user
      show_main_screen
    end

    switch_contents screen.widget
    screen.focus
  end

  def fetch_games
    @games = Server.get("/games").select { _1[:default_version] }
  end

  def show_main_screen
    box = Gtk::Box.new :vertical, 0
    @status_bar = StatusBar.new @current_user
    @status_bar.logged_out do
      @current_user = nil
      show_login_screen
    end

    screen = GamesScreen.new @games
    screen.started_game do |game|
      @current_game = game
      launch
    end

    box.add @status_bar.widget
    box.add screen.widget
    switch_contents box
  end

  def launch
    @launcher = Launcher.new @current_game, @current_user
    @launcher.status_changed do |message|
      @status_bar.set_status message
    end
    @launcher.progress do |fraction|
      @status_bar.set_progress fraction
    end
    @launcher.game_exited do
      @current_game = nil
      @launcher = nil
    end
    @launcher.spawn
  end
end
