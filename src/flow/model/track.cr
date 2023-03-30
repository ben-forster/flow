require "base64"

module Caldera
  module Model
    class Track
      # @param [String] Base64 representation of the track
      getter track_data : String

      # @param [String] The track identifier
      getter identifier : String

      # @param [true, false]
      getter seekable : Bool

      # @param [String] The track author.
      getter author : String

      # @param [Int64] Length in milliseconds.
      getter length : Int64

      # @param [true, false]
      getter stream : Bool

      # @param [Int64] The current position in milliseconds.
      getter position : Int64

      # @param [String] The track title.
      getter title : String

      # @param [String] The URI to the track source.
      getter uri : String

      def initialize(data)
        # track_data could maybe use a better name. It's
        # a base64 representation of a binary data representation
        # of a track=
        @track_data = data["track"]

        info = data["info"]
        @identifier = info["identifier"]
        @seekable = info["isSeekable"].to_b
        @author = info["author"]
        @length = info["length"]
        @stream = info["isStream"].to_b
        @position = info["position"]
        @title = info["title"]
        @uri = info["uri"]
        @source = info["source"]
      end

      # Decode a track from base64 track data.
      # @param [String] b64_data Base64 encoded track data, received from the Lavalink server.
      def self.from_b64(b64_data)
        data = Base64.decode64(b64_data)
        flags, version = data.unpack("NC")

        raise "Unsupported track data" if (flags >> 30) != 1

        # This is gross but it's easier than not doing it
        case version
        when 1
          title, author, length, identifier, is_stream, source = data.unpack("@7Z*xZ*Q>xZ*CxZ*")
          Track.new(
            "track": b64_data,
            "info": {
              "title": title,
              "author": author,
              "length": length,
              "identifier": identifier,
              "isStream": is_stream == 1,
              "source": source,
            },
          )
          
          title, author, length, identifier, is_stream, uri, source = data.unpack("@7Z*xZ*Q>xZ*CxxZ*xZ*xZ*")
          Track.new(
            "track":  b64_data,
            "info": {
              "title": title,
              "author": author,
              "length": length,
              "identifier": identifier,
              "isStream": is_stream == 1,
              "source": source,
              "uri": uri,
            },
          )
        else
          raise "Unsupported track version"
        end
      end
    end
  end
end
