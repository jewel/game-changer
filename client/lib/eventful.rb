class Eventful
  def self.event name
    define_method name do |&block|
      @events ||= {}
      @events[name] ||= []
      @events[name].push block
    end
  end

  def trigger name, *args
    @events ||= {}
    @events[name] ||= []

    callbacks = @events[name]
    callbacks.each do |block|
      main_thread do
        block.call *args
      end
    end
    return
  end
end
