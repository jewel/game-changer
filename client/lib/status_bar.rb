class StatusBar < Eventful
  event :logged_out

  def initialize user
    @user = user
  end

  def widget
    @label = Gtk::Label.new "Welcome, #{@user[:name]}!"
    @label.xalign = 0.0

    @cancel = Gtk::Button.new label: "Cancel"

    @progress = Gtk::ProgressBar.new
    @progress.fraction = 0

    @spinner = Gtk::Spinner.new
    @spinner.set_size_request 32, 32
    @spinner.start

    vbox = Gtk::Box.new :vertical, 5
    hbox = Gtk::Box.new :horizontal, 10

    vbox.add @progress
    vbox.add hbox

    hbox.pack_start @spinner, padding: 5
    hbox.pack_start @cancel, padding: 5
    hbox.pack_start @label, expand: true, fill: true, padding: 5
    hbox.pack_start user_icon, padding: 5
    vbox
  end

  def set_progress fraction
    @progress.fraction = fraction
  end

  def set_status text
    @label.text = text
  end

  private

  def user_icon
    button = Gtk::Button.new
    button.add RemoteIcon.widget @user, 32
    button.signal_connect 'clicked' do
      trigger :logged_out
    end
    button
  end
end
