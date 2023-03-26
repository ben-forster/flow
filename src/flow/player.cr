require "log"
require "json"

module Flow
    class Player
    include EventEmitter

    # @visibility private
    Log = ::Log.for(self)

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
    end

    def register_node_handlers()
    end
end
