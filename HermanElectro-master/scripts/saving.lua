local P = {}
saving = P

local isRecording = false
local input = {}
local startTime = 0
local recordingSeed = 0

local isPlayingBack = false
local currentRecording = {}
local recordingStartTime = 0
local currentRecordingIndex = 1
local playbackSeed = 0

function P.createNewRecording(seed)
	P.endRecording()
	isRecording = true
	startTime = love.timer.getTime()
	input = {}
	recordingSeed = seed
end

function P.recordKeyPressed(key, unicode)
	if key == 'z' then
		local recording = util.readJSON(saveDir..'/save.json')
		P.playRecording(recording)
		return
	end
	if not isRecording then
		return
	end
	if key == 'r' then return end
	if key == 'x' then
		P.endRecording()
		return
	end
	local time = gameTime.totalTime
	input[#input+1] = {time = time, input = {key = key, unicode = unicode}}
end

function P.endRecording()
	isRecording = false
	local recordingToSave = {inputs = input, seed = recordingSeed, character = player.character.name}
	util.writeJSON('save.json', recordingToSave)
end

function P.playRecording(recording)
	for i = 1, #characters do
		if characters[i].name == recording.character then
			player.character = characters[i]
		end
	end
	currentRecording = recording.inputs
	recordingStartTime = love.timer.getTime()
	currentRecordingIndex = 1
	recordingGameTime = recording.time
	local oldSeedOverride = seedOverride
	seedOverride = recording.seed
	startGame()
	seedOverride = oldSeedOverride
	isPlayingBack = true
	gameSpeed = 2
end

local function sendInputFromRecording(input)
	if input.key ~= nil then
		keyTimer.timeLeft = -1 --hack to skip the key timer, which could be slightly off
		love.keypressed(input.key, input.unicode)
	else

	end
end

function P.sendNextInputFromRecording()
	if not isPlayingBack then
		return
	end
	local nextInput = currentRecording[currentRecordingIndex]
	while(nextInput.time <= gameTime.totalTime) do
		if nextInput.time <= gameTime.totalTime then
			sendInputFromRecording(nextInput.input)
			currentRecordingIndex = currentRecordingIndex + 1
		end
		nextInput = currentRecording[currentRecordingIndex]
		if nextInput == nil then
			P.endPlayback()
			return
		end
	end
end

function P.endPlayback()
	isPlayingBack = false
	gameSpeed = 1
end

return saving