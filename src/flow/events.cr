require "flow/model"

module Flow
  module Events
    class TrackStart
      getter track : Flow::Model::Track
      getter player : Player

      def initialize(data, player)
        @player = player
        @track = Flow::Model::Track.from_b64(data["track"])
      end
    end

    class TrackEnd
      getter reason : Symbol
      getter guild_id : String?
      getter track : Flow::Model::Track
      getter player : Player

      def initialize(data, player)
        @player = player
        @reason = data["reason"].to_sym
        @guild_id = data["guildId"]?.as(String?)
        @track = Flow::Model::Track.from_b64(data["track"])
      end
    end

    class TrackException
      getter player : Player
      getter error : String
      getter track : Flow::Model::Track

      def initialize(data, player)
        @player = player
        @error = data["error"]
        @track = Flow::Model::Track.from_b64(data["track"])
      end
    end

    class TrackStuck
      getter player : Player
      getter threshold : Int32
      getter track : Flow::Model::Track

      def initialize(data, player)
        @player = player
        @threshold = data["thresholdMs"].as(Int32)
        @track = Flow::Model::Track.from_b64(data["track"])
      end
    end

    class WebSocketClosed
      getter guild_id : String?
      getter code : Int32
      getter reason : String
      getter by_remote : Bool

      def initialize(data, _player)
        @guild_id = data["guildId"]?.as(String?)
        @code = data["code"].as(Int32)
        @reason = data["reason"]
        @by_remote = data["byRemote"].as(Bool)
      end
    end

    class StatsEvent
      Memory = Struct.new(reservable : Int64, used : Int64, free : Int64, allocated : Int64)
      Cpu = Struct.new(cores : Int32, system_load : Float64, lavalink_load : Float64, uptime : Int64)

      getter playing_players : Int32
      getter memory : Memory
      getter cpu : Cpu
      getter uptime : Int64

      def initialize(data, _node)
        @playing_players = data["playingPlayers"].as(Int32)
        @memory = Memory.new(
          reservable: data["memory"]["reservable"].as(Int64),
          used: data["memory"]["used"].as(Int64),
          free: data["memory"]["free"].as(Int64),
          allocated: data["memory"]["allocated"].as(Int64)
        )

        cpu_data = data["cpu"]
        snake_case_data = {
          cores: cpu_data["cores"].as(Int32),
          system_load: cpu_data["systemLoad"].as(Float64),
          lavalink_load: cpu_data["lavalinkLoad"].as(Float64)
        }
        @cpu = Cpu.new(**snake_case_data)
        @uptime = data["uptime"].as(Int64)
      end
    end

    class PlayerUpdateEvent
      getter player : Player
      getter time : Time
      getter position : Int64

      def initialize(data, player)
        @player = player
        @time = Time.at(data["time"])
        @position = data["position"].to_i32
            end
        end
    end
end