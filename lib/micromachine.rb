class MicroMachine
  InvalidEvent = Class.new(NoMethodError)

  attr :transitions_for
  attr :state

  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  def on key, &block
    @callbacks[key] << block
  end

  def when(event, transitions)
    transitions_for[event] = transitions
  end

  def trigger event, *args
    if trigger?(event)
      @state_was, @state = state, transitions_for[event][state]
      callbacks = @callbacks[state] + @callbacks[:any]
      result = callbacks.all? { |callback| callback.call(*args) != false }
      @state = @state_was unless result

      return result
    end

    false
  rescue
    @state = @state_was
    raise
  end

  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    !!transitions_for[event][state]
  end

  def events
    transitions_for.keys
  end

  def ==(some_state)
    state == some_state
  end
end
