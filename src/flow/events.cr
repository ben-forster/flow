require "flow/model"
require "event_handler"

module Flow
  module Events
    class TrackStart
      include EventHandler::Event

      getter track : Flow::Model::Track
      getter player : Player

      def initialize(@track : String, @player : Player)
        @track = Flow::Model::Track.from_b64(@track)
      end
    end

    class TrackEnd
      include EventHandler::Event

      getter reason : Symbol
      getter guild_id : String
      getter track : Flow::Model::Track
      getter player : Player

      def initialize(@reason : String, @guild_id : String, @track : String, @player : Player)
        @reason = @reason.to_sym
        @track = Flow::Model::Track.from_b64(@track)
      end
    end

    class TrackException
      include EventHandler::Event

      getter error : String
      getter track : Flow::Model::Track
      getter player : Player

      def initialize(@error : String, @track : String, @player : Player)
        @track = Flow::Model::Track.from_b64(@track)
      end
    end

    class TrackStuck
      include EventHandler::Event

      getter threshold : Int32
      getter track : Flow::Model::Track
      getter player : Player

      def initialize(@threshold : Int32, @track : String, @player : Player)
        @track = Flow::Model::Track.from_b64(@track)
      end
    end

    class WebSocketClosed
      include EventHandler::Event

      getter guild_id : String
      getter code : Int32
      getter reason : String
      getter by_remote : Bool

      def initialize(@guild_id : String, @code : Int32, @reason : String, @by_remote : Bool)
      end
    end

    class StatsEvent
      include EventHandler::Event

      Memory = Struct.new(reservable : Int32, used : Int32, free : Int32, allocated : Int32)
      Cpu = Struct.new(cores : Int32, system_load : Float32, lavalink_load : Float32, uptime : Int32)

      getter playing_players : Int32
      getter memory : Memory
      getter cpu : Cpu
      getter uptime : Int32

      def initialize(@playing_players : Int32, @memory : Hash(String, Int32), @cpu : Hash(String, Float32), @uptime : Int32)
        memory_data = @memory.map { |k, v| [k.to_sym, v] }.to_h
        cpu_data = @cpu.map { |k, v| [k.to_sym, v] }.to_h

        snake_case_data = {
          cores: cpu_data[:cores],
          system_load: cpu_data[:system_load],
          lavalink_load: cpu_data[:lavalink_load]
        }

        @memory = Memory.new(**memory_data)
        @cpu = Cpu.new(**snake_case_data, uptime: @uptime)
      end
    end

    class PlayerUpdateEvent
      include EventHandler::Event

      getter player : Player
      getter time : Time
      getter position : Int64

      def initialize(@time : Int64, @position : Int64, @player : Player)
        @time = Time.at(@time)
      end
    end
  end
end
