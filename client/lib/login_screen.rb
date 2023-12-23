require_relative 'remote_icon'

class LoginScreen < Eventful
  event :user_chosen

  def initialize users
    @users = users
  end

  def widget
    margin_box = Gtk::Box.new :vertical, 5
    margin_box.set_valign Gtk::Align::START
    margin_box.set_halign Gtk::Align::CENTER

    margin_box.add logo_image

    list_box = Gtk::ListBox.new
    margin_box.add list_box

    # list_box.set_selection_mode Gtk::SelectionMode::NONE
    list_box.set_valign Gtk::Align::CENTER
    list_box.set_halign Gtk::Align::CENTER

    if @users.empty?
      margin_box.add Gtk::Label.new "Error: No users set up"
    end

    @users.each do |user|
      row = Gtk::ListBoxRow.new
      list_box.add row

      button = Gtk::Button.new
      row.add button

      box = Gtk::Box.new :horizontal, 20
      button.add box

      box.add RemoteIcon.widget(user, 64)

      label = Gtk::Label.new user[:name]
      box.add label

      button.signal_connect 'clicked' do
        trigger :user_chosen, user
      end
    end

    margin_box
  end

  private

  def logo_image
    pixbuf = GdkPixbuf::Pixbuf.new file: File.dirname(__FILE__) + "/../logo.svg"
    height = 300
    aspect_ratio = pixbuf.width.to_f / pixbuf.height.to_f
    new_width = (height * aspect_ratio).round
    scaled_pixbuf = pixbuf.scale_simple new_width, height, GdkPixbuf::InterpType::BILINEAR
    image = Gtk::Image.new pixbuf: scaled_pixbuf
    image
  end
end
