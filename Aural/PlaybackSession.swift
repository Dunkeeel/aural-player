import Cocoa
import AVFoundation

/*
    Represents a playback session, which begins with either the user requesting a new track (by clicking Play/Next track/Previous track/Play selected track) or the player plays the next track in the sequence upon completion of the previous one. The session ends when a new request is received or playback of the current session completes.
 
    The lifecycle of a session is as follows:
 
    start() -> Session is now current
    end() -> Session is no longer current. There is no current session.
 
    If a new session is started while the current one is still active (playing), the old one is implicitly ended, and the new session becomes both current. In other words, the following code will start session1, then start session2, ending session1 ...
 
    start() -> starts session1
    start() -> starts session2, ending session1
 
    During its lifespan, the playback session can have one of three states:
 
    1 - Scheduling and playback both ongoing
 
    This is the initial state, and indicates that buffer scheduling and playback are to continue normally.
 
    2 - Scheduling completed, playback ongoing
 
    This occurs when the end of file (EOF) is encountered when scheduling a buffer. This indicates that no more scheduling is to be done. However, this does not affect playback, which continues normally.
 
    3 - Scheduling completed, playback completed
 
    This occurs when the last buffer has finished playing back. Both scheduling and playback are stopped, and observers are notified of playback completion.
 
    -------------------------
 
    Note that, because of the look ahead scheduling algorithm, the EOF will be reached a few seconds before playback actually completes. This is state 2. Then, playback completes, and that is the terminal state 3.
 */
class PlaybackSession {
    
    // Holds the current playback session
    static var currentSession: PlaybackSession?
    
    // The track associated with this session
    let track: Track
    
    var schedulingCompleted: Bool = false
    var playbackCompleted: Bool = false
    
    private init(_ track: Track) {
        self.track = track
    }
    
    // Start a new session, implicitly invalidating the old one (if there was one), and returns it
    static func start(_ track: Track) -> PlaybackSession {
        currentSession = PlaybackSession(track)
        return currentSession!
    }
    
    // End the current session
    static func endCurrent() {
        currentSession = nil
    }
    
    // Compares the current session to a given session for equality
    static func isCurrent(_ session: PlaybackSession) -> Bool {
        return currentSession != nil && (session === currentSession)
    }
}
