require "discordcr"
require "flow"

  intents = Discord::Gateway::Intents::Guilds | Discord::Gateway::Intents::GuildMessages | Discord::Gateway::Intents::GuildPresences | Discord::Gateway::Intents::GuildMembers

  # Make sure to replace this fake data with actual data when running.
  client = Discord::Client.new(token: "Bot your_token_here", client_id: 124567890_u64,  intents: intents)
  cache = Discord::Cache.new(client)
  client.cache = cache

  PREFIX = "!"

  client.on_ready do |event|
    client.status_update(game: Discord::GamePlaying.new(name: "Playing music!", type: :playing))
    puts("Logged in successfully.")
  end

    command = payload.content.downcase 
    server_id = payload.guild_id

    case command
    when PREFIX + "play"
      embed = Discord::Embed.new(description: "**Now Playing: **", title: "", colour: 0xCCCCFF_i32, type: "rich")
      m = client.create_message(payload.channel_id, "", embed)
    end

client.run