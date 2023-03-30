module Flow
    module Model
      # Represents the struct returned from {Client#load_tracks}
      class LoadTracks
        include Enumerable(Track)
  
        # @return [PlaylistInfo]
        getter playlist_info : PlaylistInfo
  
        # @return [Array<Track>]
        getter tracks : Array(Track)
  
        # @return [:TRACK_LOADED, :PLAYLIST_LOADED, :SEARCH_RESULT, :NO_MATCHES, :LOAD_FAILED]
        getter load_type : Symbol
  
        def initialize(data)
          playlist_info = data["playlistInfo"]
          @playlist_info = PlaylistInfo.new(playlist_info) if playlist_info
          @tracks = data["tracks"].map { |track_data| Model::Track.new(track_data) }
          @load_type = data["loadType"].to_sym
        end
  
        # Operate on each track.
        # @yieldparam [Track]
        def each(&block)
          @tracks.each(&block)
        end
      end
    end
  end