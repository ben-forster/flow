require "flow/model"
require "flow/events"
require "event_handler"
require "log"
require "json"

module Flow
    class Player
    include EventHandler

    # @visibility private
    LOGGER = ::Log.for(self)

    # @return [String]
    getter guild_id

    # @return [Node] The node that owns this player.
    getter node

    # @return [Integer]
    getter volume

    # @return [true, false]
    getter paused

    # @return [Integer]
    getter position

    # @return [Time]
    getter time

    # @return [Track]
    getter track
    getter now_playing
        @track

    def initialize(@guild_id : UInt64, @node : Node, @client : Client)
        @guild_id = guild_id
        @node = node
        @client = client
        @volume = 100
        @paused = false
        @position = 0
        @time = 0

        register_node_handlers()
    end

    # Play a track.
    # @param [String, Track] Either a base64 encoded track, or a {Track} object.
    # @param [Integer] start_time The time in milliseconds to begin playback at.
    # @param [Integer] end_time The time in milliseconds to end at.
    def play(track, start_time = 0, end_time = 0)
        @paused = false
        @track = track

        send_packet(:play, {
            track: track.is_a?(Model::Track) ? track.track_data : track,
            startTime: start_time,
            endTime: end_time,
            noReplace: false
          })
        end

    # Pause playback.
    def pause
        send_packet(:pause, {
            pause: true
        })
    end

    # Resume the player.
    def unpause
        send_packet(:pause, {
            pause: false
        })
    end

    # Seek to a position in the track.
    # @param [Integer] position The position to seek to, in millisconds.
    def seek(position : Int32)
        send_packet(:seek, {
                      position: position.to_i32
                    })
    end

    # Set the volume of the player
    # @param [Integer] level A value between 0 and 1000.
    def volume=(level : Int32)
        send_packet(:volume, {
                    volume: level.clamp(0, 1000).to_i32
                    })
    end

    # Adjust the gain of bands.
    # @example
    #   player.equalizer(1 => 0.25, 5 => -0.25, 10 => 0.0)
    def equalizer(**bands)
        send_packet(:equalizer, {
        bands: bands.map { |band, gain| { band: band.to_i, gain: gain.to_f } }
        })
    end

    # Destroy this player
    def destroy
        send_packet(:destroy)
      end

    # @visibility private
    def state=(new_state)
        @time = Time.at(new_state["time"])
        @position = new_state["position"]
    end

    # See Node#load_tracks
    def load_tracks(*args, **opts)
        @node.load_tracks(*args, **opts)
    end

    private def send_packet(op, data = {} of String => JSON::Any)
        packet = { op: op, guildId: @guild_id }.merge(data)
        LOGGER.debug { "Sending packet to node: #{packet}" }
        @node.send_json(packet)
    end

    def register_node_handlers
        node.on(:track_start) { |*args| handle_track_start(*args) }
        node.on(:track_end) { |*args| handle_track_end(*args) }
        node.on(:track_exception) { |*args| handle_track_exception(*args) }
        node.on(:track_stuck) { |*args| handle_track_stuck(*args) }
        node.on(:websocket_closed) { |*args| handle_websocket_closed(*args) }
      end  
  
      private def handle_track_start(track_data)
        puts "Track started for #{@guild_id}"
        trigger("track_start", Events::TrackStart.new(track_data, self))
      end
    
      def handle_track_end(track)
        puts "Track ended for #{@guild_id}"
        @track = nil
        trigger("track_end", Events::TrackEnd.new(track, self))
      end
    
      def handle_track_exception(track)
        puts "Track exception for #{@guild_id}"
        @track = nil
        trigger("track_exception", Events::TrackException.new(track, self))
      end
    
      private def handle_track_stuck(track)
        puts "Track stuck for #{@guild_id}"
        @track = nil
        trigger("track_stuck", Events::TrackStuck.new(track, self))
      end
    
      private def handle_websocket_closed(code, reason, by_remote)
        puts "WebSocket closed for #{@guild_id}"
        @track = nil
        trigger("websocket_closed", Events::WebSocketClosed.new(code, reason, by_remote, self))
      end
    end
end
