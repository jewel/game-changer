class PasswordScreen < Eventful
  event :logged_in
  event :cancelled

  def initialize user
    @user = user
  end

  def widget
    hbox = Gtk::Box.new :horizontal, 50
    hbox.set_valign Gtk::Align::CENTER
    hbox.set_halign Gtk::Align::CENTER

    icon = RemoteIcon.widget @user, 320
    hbox.add icon

    vbox = Gtk::Box.new :vertical, 5
    hbox.add vbox

    vbox.add Gtk::Label.new "User:"
    entry = Gtk::Entry.new
    entry.text = @user[:name]
    entry.sensitive = false

    vbox.add entry
    vbox.add Gtk::Label.new "Password:"

    @entry = Gtk::Entry.new
    @entry.visibility = false
    @entry.signal_connect "changed" do
      @entry.style_context.remove_class "error"
    end

    vbox.add @entry

    @entry.signal_connect 'activate' do
      check_password
    end

    button = Gtk::Button.new label: "Login"
    button.signal_connect 'clicked' do
      check_password
    end

    cancel = Gtk::Button.new label: "Cancel"
    cancel.signal_connect 'clicked' do
      trigger :cancelled
    end

    vbox.add button
    vbox.add cancel

    hbox
  end

  def focus
    @entry.grab_focus
  end

  def check_password
    if @entry.text == @user[:password]
      trigger :logged_in, @user
    else
      @entry.style_context.add_class "error"
    end
  end
end
