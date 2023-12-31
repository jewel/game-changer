class RemoteIcon
  class << self
    def widget obj, size
      hash = obj[:icon] || ""
      if hash == ""
        icon = Gtk::DrawingArea.new
        icon.set_size_request size, size
        icon.signal_connect "draw" do |widget, cr|
          # Pick a random color based on the ID
          r = Random.new obj[:id]
          cr.set_source_rgb r.rand, r.rand, r.rand
          cr.rectangle 0, 0, widget.allocated_width, widget.allocated_height
          cr.fill
        end
        return icon
      end

      placeholder = Gtk::Box.new :vertical, 0
      placeholder.set_size_request size, size
      start_download hash, size, placeholder
      placeholder
    end

    private

    def start_download *args
      @queue ||= Queue.new
      @queue.push args

      return if @worker

      # First download attempt, launch a thread to do all future downloads
      @worker = Thread.new do
        while info = @queue.shift
          download *info
        end
      end
    end

    def download hash, size, placeholder
      picture = Server.fetch_bucket hash
      main_thread do
        loader = GdkPixbuf::PixbufLoader.new
        loader.write picture
        loader.close
        pixbuf = loader.pixbuf

        aspect_ratio = pixbuf.width.to_f / pixbuf.height.to_f
        new_width = (size * aspect_ratio).round
        new_height = size
        if new_width > size
          new_width = size
          new_height = (size / aspect_ratio).round
        end
        scaled_pixbuf = pixbuf.scale_simple new_width, new_height, GdkPixbuf::InterpType::BILINEAR
        placeholder.add Gtk::Image.new pixbuf: scaled_pixbuf
        placeholder.show_all
      end
    end
  end
end
