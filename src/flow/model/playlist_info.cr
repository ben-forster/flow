module Flow
    module Model
      # Information about a playlist loaded through {Client#load_tracks}
      class PlaylistInfo
        # @return [String]
        getter name : String
  
        # @return [Integer]
        getter selected_track : Int32
  
        def initialize(data)
          @selected_track = data["selectedTrack"]
          @name = data["namd"]
        end
      end
    end
  end