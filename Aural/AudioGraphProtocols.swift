import Cocoa
import AVFoundation

/*
    Contract for operations to alter the audio graph, i.e. tune the sound output - volume, panning, equalizer (EQ), and sound effects
 */
protocol AudioGraphProtocol {
    
    // Retrieves the current player volume
    func getVolume() -> Float
    
    // Sets the player volume, specified as a value between 0 and 1
    func setVolume(_ volume: Float)
    
    // Retrieves the current stereo L/R balance (aka pan)
    func getBalance() -> Float
    
    // Sets the stereo L/R balance (aka pan), specified as a value between -1 (L) and 1 (R)
    func setBalance(_ balance: Float)
    
    // Mutes the player
    func mute()
    
    // Unmutes the player
    func unmute()
    
    // Determines whether the player is currently muted
    func isMuted() -> Bool
    
    // Sets global gain (or preamp) for the equalizer
    func setEQGlobalGain(_ gain: Float)
    
    // Sets the gain value of a single equalizer frequency band
    func setEQBand(_ freq: Int , gain: Float)
    
    // Sets the gain values of multiple equalizer frequency bands (when using an EQ preset)
    func setEQBands(_ bands: [Int: Float])
    
    // Toggles the bypass state of the pitch shift audio effect unit, and returns its new bypass state
    func togglePitchBypass() -> Bool
    
    // Sets the pitch shift value, in cents, specified as a value between -2400 and 2400
    func setPitch(_ pitch: Float)
    
    // Sets the amount of overlap between segments of the input audio signal into the pitch effects unit, specified as a value between 3 and 32
    func setPitchOverlap(_ overlap: Float)
    
    // Toggles the bypass state of the time audio effect unit, and returns its new bypass state
    func toggleTimeBypass() -> Bool
    
    // Returns the current bypass state of the time audio effect unit
    func isTimeBypass() -> Bool
    
    // Sets the playback rate, specified as a value between 1/32 and 32
    func setTimeStretchRate(_ rate: Float)
    
    // Sets the amount of overlap between segments of the input audio signal into the time effects unit, specified as a value between 3 and 32
    func setTimeOverlap(_ overlap: Float)
    
    // Toggles the bypass state of the reverb audio effect unit, and returns its new bypass state
    func toggleReverbBypass() -> Bool
    
    // Sets the reverb preset. See ReverbPresets for more details.
    func setReverb(_ preset: ReverbPresets)
    
    // Sets the reverb amount, specified as a value between 0 (dry) and 100 (wet)
    func setReverbAmount(_ amount: Float)
    
    // Toggles the bypass state of the delay audio effect unit, and returns its new bypass state
    func toggleDelayBypass() -> Bool
    
    // Sets the delay (echo) amount, specified as a value between 0 (dry) and 100 (wet)
    func setDelayAmount(_ amount: Float)
    
    // Sets the delay time, in seconds, specified as a value between 0 and 2
    func setDelayTime(_ time: Double)
    
    // Sets the delay feedback, in percentage, specified as a value between -100 and 100
    func setDelayFeedback(_ percent: Float)
    
    // Sets the delay low pass cutoff frequency, in Hz, specified as a value between 10 and 20k
    func setDelayLowPassCutoff(_ cutoff: Float)
    
    // Toggles the bypass state of the filter audio effect unit, and returns its new bypass state
    func toggleFilterBypass() -> Bool
    
    // Sets the bass band of the filter to the specified frequency range
    func setFilterBassBand(_ min: Float, _ max: Float)
    
    // Sets the mid band of the filter to the specified frequency range
    func setFilterMidBand(_ min: Float, _ max: Float)
    
    // Sets the treble band of the filter to the specified frequency range
    func setFilterTrebleBand(_ min: Float, _ max: Float)
    
    // Returns all state of the audio graph that needs to be persisted to disk
    func getPersistentState() -> AudioGraphState
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
}

/*
    Contract for a sub-graph of the audio graph, suitable for a player, that performs operations on only the player node of the graph.
 */
protocol PlayerGraphProtocol {
    
    // The audio graph node responsible for playback
    var playerNode: AVAudioPlayerNode {get}
    
    // Reconnects the player node to its output node, with a new audio format
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat)
    
    // Clears reverb/delay sound tails. Suitable for use when stopping the player.
    func clearSoundTails()
}

/*
    Contract for a sub-graph of the audio graph, suitable for a recorder, that has access to only the graph node on which a recorder tap can be installed.
 */
protocol RecorderGraphProtocol {
 
    // The audio graph node on which a recorder tap can be installed
    var nodeForRecorderTap: AVAudioNode {get}
}
