import Cocoa

/*
    Contract for an audio player that performs track playback
 */
protocol PlayerProtocol {
    
    // Plays a given track
    func play(_ track: Track)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Stops playback of the currently playing track
    func stop()
    
    // Seeks to a certain time in the track
    func seekToTime(_ track: Track, _ seconds: Double)
    
    // Gets the playback position (in seconds) of the currently playing track
    func getSeekPosition() -> Double
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
}
