local io = require("io")
local http = require("socket.http")
local ltn12 = require("ltn12")

--TODO: figure out identity token generation
--TODO: write HTTP code
--TODO: write checksum code

--returns the daily seed, or 0 if daily alread completed by this token
function getDaily(identityToken)
	--makes an http request
end

--reports score to the server
function reportScore(identityToken, didDie, score)
	--generate checksum and make http request
end

--gets a JSON file with current leaderboard standings
function getLeaderboards()
	 --makes an http request
end