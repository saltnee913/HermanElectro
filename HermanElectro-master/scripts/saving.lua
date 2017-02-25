local P = {}
saving = P

P.saveFile = 'save.json'
P.replayDir = 'Replays'
P.replayFile = 'replay' -- #.json automatically appended (example: Replays/replay5.json)
P.replaySpeed = 1

local isRecording = false
local input = {}
local recordingSeed = 0
local unlocksSave = {}
local saveNumber = 0

local isPlayingBack = false
local currentRecording = {}
local currentRecordingIndex = 1
local playbackSeed = 0
local isReplay = false

function P.createNewRecording(seed)
	P.endRecording()
	isRecording = true
	input = {}
	recordingSeed = seed
	for i = 1, #unlocks do
		unlocksSave[i] = unlocks[i].unlocked
	end
	saveNumber = stats.runNumber
end

function P.recordKeyPressed(key, unicode, isRepeat)
	if not isRecording then
		return
	end
	if key == 'r' then return end
	local time = gameTime.totalTime
	input[#input+1] = {time = time, input = {key = key, unicode = unicode, isRepeat = isRepeat}}
end

function P.recordMouseInput(x, y, button, isTouch, isRelease)
	if not isRecording then
		return
	end
	local time = gameTime.totalTime
	input[#input+1] = {time = time, input = {x = x, y = y, button = button, isTouch = isTouch, isRelease = isRelease}}
end

function P.recordMouseMoved(x, y, dx, dy, isTouch)
	if not isRecording then
		return
	end
	local time = gameTime.totalTime
	input[#input+1] = {time = time, input = {x = x, y = y, dx = dx, dy = dy, isTouch = isTouch}}
end

function P.saveRecording()
	if isPlayingBack then
		return
	end
	local recordingToSave = {inputs = input, seed = recordingSeed, character = player.character.name, 
	  isDead = player.dead, unlocksSave = unlocksSave, saveNumber = saveNumber}
	util.writeJSON(P.saveFile, recordingToSave)
	util.writeJSON(P.replayFile..saveNumber..'.json', recordingToSave, nil, P.replayDir)
end

function P.endRecording()
	if not isRecording then
		return
	end
	isRecording = false
	P.saveRecording()
end


function P.getSave()
	if not love.filesystem.exists(saveDir..'/'..P.saveFile) then 
		return nil
	end
	return util.readJSON(saveDir..'/'..P.saveFile, false)
end

function P.getReplay(replayNumber)
	if not love.filesystem.exists(saveDir..'/'..P.replayDir..'/'..P.replayFile..replayNumber..'.json') then
		return nil
	else
		return util.readJSON(saveDir..'/'..P.replayDir..'/'..P.replayFile..replayNumber..'.json', false)
	end
end

function P.getLatestReplay()
	local save = P.getSave()
	if save ~= nil and save.isDead then
		return save
	elseif save ~= nil then
		return P.getReplay(save.saveNumber-1)
	else
		return P.getReplay(stats.runNumber)
	end
end


function P.isPlayingBack()
	return isPlayingBack
end

function P.playRecording(recording)
	isPlayingBack = true
	for i = 1, #characters do
		if characters[i].name == recording.character then
			player.character = characters[i]
		end
	end
	for i = 1, #unlocks do
		unlocks[i].unlocked = recording.unlocksSave[i]
	end
	currentRecording = recording.inputs
	currentRecordingIndex = 1
	recordingGameTime = recording.time
	local oldSeedOverride = seedOverride
	seedOverride = recording.seed
	startGame()
	seedOverride = oldSeedOverride
end

function P.playBackRecording(recording)
	isReplay = true
	P.playRecording(recording)
	gameSpeed = P.replaySpeed
end

function P.playRecordingFast(recording)
	isReplay = false
	P.playRecording(recording)
	while(currentRecordingIndex <= #recording.inputs) do
		love.update(0.01)
	end
	isRecording = true
	input = recording.inputs
	recordingSeed = recording.seed
	unlocksSave = recording.unlocksSave
	saveNumber = recording.saveNumber
	P.endPlayback()
end

local function sendInputFromRecording(input)
	if input.key ~= nil then
		keyTimer.timeLeft = -1 --hack to skip the key timer, which could be slightly off
		love.keypressed(input.key, input.unicode, input.isRepeat, true)
	elseif input.isRelease == nil then
		love.mousemoved(input.x, input.y, input.dx, input.dy, input.isTouch, true)
	elseif input.isRelease then
		love.mousereleased(input.x, input.y, input.button, input.isTouch, true)
	else
		love.mousepressed(input.x, input.y, input.button, input.isTouch, true)
	end
end

function P.sendNextInputFromRecording()
	if not isPlayingBack then
		return
	end
	local nextInput = currentRecording[currentRecordingIndex]
	if nextInput == nil then
		if isReplay then
			gameSpeed = 0
		end
		return
	end
	if nextInput.time <= gameTime.totalTime then
		sendInputFromRecording(nextInput.input)
		currentRecordingIndex = currentRecordingIndex + 1
	end
	nextInput = currentRecording[currentRecordingIndex]
end

function P.endPlayback()
	isPlayingBack = false
	gameSpeed = 1
	gamePaused = false
end

return saving