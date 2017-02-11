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
	isRecording = true
	startTime = love.timer.getTime()
	input = {}
	recordingSeed = seed
end

function P.recordKeyPressed(key, unicode)
	if not isRecording then
		return
	end
	local time = love.timer.getTime() - startTime
	input[#input+1] = {time = time, input = {key = key, unicode = unicode}}
end

function P.playRecording(recording)
	currentRecording = recording.inputs
	recordingStartTime = love.timer.getTime()
	currentRecordingIndex = 1
	local oldSeedOverride = seedOverride
	seedOverride = recording.seed
	loadRandoms()
	seedOverride = oldSeedOverride
end

local function sendInput(input)
	if input.key ~= nil then
		love.keypressed(input.key, input.unicode)
	else

	end
end

function P.sendInputForRecording()
	if not isPlayingBack then
		return
	end
	local nextInput = currentRecording[currentRecordingIndex]
	if nextInput.time <= love.timer.getTime() - recordingStartTime then
		sendInput(nextInput.input)
		currentRecordingIndex++
		P.endPlayback()
	end
end

function P.endPlayback()
	isPlayingBack = false
end

return saving