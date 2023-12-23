css_provider = Gtk::CssProvider.new
css_provider.load data: <<-CSS
  entry.error {
    border: 1px solid red;
  }
CSS

Gtk::StyleContext.add_provider_for_screen(
  Gdk::Screen.default,
  css_provider,
  Gtk::StyleProvider::PRIORITY_APPLICATION
)
