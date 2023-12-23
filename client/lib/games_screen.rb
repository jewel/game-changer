class GamesScreen < Eventful
  event :started_game

  def initialize games
    @games = games
  end

  def widget
    grid = Gtk::FlowBox.new
    grid.set_valign Gtk::Align::CENTER
    grid.set_halign Gtk::Align::CENTER

    if @games.empty?
      grid.add Gtk::Label.new "Error: No games configured"
    end

    @games.each do |game|
      button = Gtk::Button.new
      grid.add button
      box = Gtk::Box.new :vertical, 20
      button.add box

      button.signal_connect 'clicked' do
         trigger :started_game, game
      end

      box.add RemoteIcon.widget(game, 256)

      label = Gtk::Label.new game[:name]
      box.add label
    end

    grid
  end
end
