module HTTP2
  # Implementation of stream and connection DATA flow control: frames may
  # be split and / or may be buffered based on current flow control window.
  #
  module FlowBuffer
    # Amount of buffered data. Only DATA payloads are subject to flow stream
    # and connection flow control.
    #
    # @return [Integer]
    def buffered_amount
      @send_buffer.map { |f| f[:length] }.reduce(:+) || 0
    end

    private

    def update_local_window(frame)
      frame_size = frame[:payload].bytesize
      frame_size += frame[:padding] || 0
      @local_window -= frame_size
    end

    def calculate_window_update(window_max_size)
      # If DATA frame is received with length > 0 and
      # current received window size + delta length is strictly larger than
      # local window size, it throws a flow control error.
      #
      error(:flow_control_error) if @local_window < 0

      # Send WINDOW_UPDATE if the received window size goes over
      # the local window size / 2.
      #
      # The HTTP/2 spec mandates that every DATA frame received
      # generates a WINDOW_UPDATE to send. In some cases however,
      # (ex: DATA frames with short payloads),
      # the noise generated by flow control frames creates enough
      # congestion for this to be deemed very inefficient.
      #
      # This heuristic was inherited from nghttp, which delays the
      # WINDOW_UPDATE until at least half the window is exhausted.
      # This works because the sender doesn't need those increments
      # until the receiver window is exhausted, after which he'll be
      # waiting for the WINDOW_UPDATE frame.
      return unless @local_window <= (window_max_size / 2)
      window_update(window_max_size - @local_window)
    end

    # Buffers outgoing DATA frames and applies flow control logic to split
    # and emit DATA frames based on current flow control window. If the
    # window is large enough, the data is sent immediately. Otherwise, the
    # data is buffered until the flow control window is updated.
    #
    # Buffered DATA frames are emitted in FIFO order.
    #
    # @param frame [Hash]
    # @param encode [Boolean] set to true by co
    def send_data(frame = nil, encode = false)
      @send_buffer.push frame unless frame.nil?

      # FIXME: Frames with zero length with the END_STREAM flag set (that
      # is, an empty DATA frame) MAY be sent if there is no available space
      # in either flow control window.
      while @remote_window > 0 && !@send_buffer.empty?
        frame = @send_buffer.shift

        sent, frame_size = 0, frame[:payload].bytesize

        if frame_size > @remote_window
          payload = frame.delete(:payload)
          chunk   = frame.dup

          # Split frame so that it fits in the window
          # TODO: consider padding!
          frame[:payload] = payload.slice!(0, @remote_window)
          chunk[:length]  = payload.bytesize
          chunk[:payload] = payload

          # if no longer last frame in sequence...
          frame[:flags] -= [:end_stream] if frame[:flags].include? :end_stream

          @send_buffer.unshift chunk
          sent = @remote_window
        else
          sent = frame_size
        end

        manage_state(frame) do
          frames = encode ? encode(frame) : [frame]
          frames.each { |f| emit(:frame, f) }
          @remote_window -= sent
        end
      end
    end

    def process_window_update(frame)
      return if frame[:ignore]
      @remote_window += frame[:increment]
      send_data
    end
  end
end