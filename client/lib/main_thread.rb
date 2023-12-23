# Helper method to get work from a thread back onto the main thread

module Kernel
  def main_thread method=nil
    GLib::Idle.add do
      if method
        send method
      elsif block_given?
        yield
      else
        raise "Nothing to do"
      end
      false
    end
  end
end
