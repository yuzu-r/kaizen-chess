GAMES_URI = ENV["firebase_database_url"] + '/games/'
FB = Firebase::Client.new(GAMES_URI)