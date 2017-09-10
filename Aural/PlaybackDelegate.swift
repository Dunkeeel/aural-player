import Foundation

class PlaybackDelegate: PlaybackDelegateProtocol, BasicPlaybackDelegateProtocol, PlaylistChangeListener, EventSubscriber {
    
    private let player: PlayerProtocol
    private let playbackSequence: PlaybackSequenceProtocol
    private let playlist: PlaylistAccessorProtocol
    private let preferences: Preferences
    
    // Serial queue for track prep tasks (to prevent concurrent prepping of the same track which could cause contention and is unnecessary to begin with)
    private var trackPrepQueue: OperationQueue
    
    init(_ player: PlayerProtocol, _ playbackSequence: PlaybackSequenceProtocol, _ playlist: PlaylistAccessorProtocol, _ preferences: Preferences) {
        
        self.player = player
        self.playbackSequence = playbackSequence
        self.playlist = playlist
        self.preferences = preferences
        
        self.trackPrepQueue = OperationQueue()
        trackPrepQueue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        trackPrepQueue.maxConcurrentOperationCount = 1
        
        EventRegistry.subscribe(EventType.playbackCompleted, subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive))
    }
    
    func togglePlayPause() throws -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool) {
        
        var trackChanged = false
        let playbackState = player.getPlaybackState()
        
        // Determine current state of player, to then toggle it
        switch playbackState {
            
        case .noTrack: let playingTrack = try subsequentTrack()
        if (playingTrack != nil) {
            trackChanged = true
        }
            
        case .paused: resume()
            
        case .playing: pause()
            
        }
        
        return (getPlaybackState(), getPlayingTrack(), trackChanged)
    }
    
    private func subsequentTrack() throws -> IndexedTrack? {
        let track = playlist.peekTrackAt(playbackSequence.subsequent())
        try play(track)
        return track
    }
    
    private func pause() {
        player.pause()
    }
    
    private func resume() {
        player.resume()
    }
    
    func play(_ index: Int) throws -> IndexedTrack {
        playbackSequence.select(index)
        let track = playlist.peekTrackAt(index)
        try play(track)
        return track!
    }
    
    private func play(_ track: IndexedTrack?) throws {
        
        // Stop if currently playing
        stop()
        
        if (track != nil) {
            
            let session = PlaybackSession.start(track!)
            
            let actualTrack = track!.track!
            TrackIO.prepareForPlayback(actualTrack)
            
            if (actualTrack.preparationFailed) {
                throw actualTrack.preparationError!
            }
            
            player.play(session)
            
            // Prepare next possible tracks for playback
            prepareNextTracksForPlayback()
        }
    }
    
    // Computes which tracks are likely to play next (based on the playback sequence and user actions), and eagerly loads metadata for those tracks in preparation for their future playback. This significantly speeds up playback start time when the track is actually played back.
    private func prepareNextTracksForPlayback() {
        
        // Set of all tracks that need to be prepped
        let prepTracksSet = NSMutableSet()
        
        // The three possible tracks that could play next
        let peekSubsequent = playlist.peekTrackAt(playbackSequence.peekSubsequent())?.track
        let peekNext = playlist.peekTrackAt(playbackSequence.peekNext())?.track
        let peekPrevious = playlist.peekTrackAt(playbackSequence.peekPrevious())?.track
        
        let playingTrack = getPlayingTrack()
        
        // Add each of the three tracks to the set of tracks to be prepped, as long as they're non-nil and not equal to the playing track (which has already been prepped, since it is playing)
        if (peekSubsequent != nil && playingTrack?.track !== peekSubsequent) {
            prepTracksSet.add(peekSubsequent!)
        }
        
        if (peekNext != nil) {
            prepTracksSet.add(peekNext!)
        }
        
        if (peekPrevious != nil) {
            prepTracksSet.add(peekPrevious!)
        }
        
        if (prepTracksSet.count > 0) {
            
            for _track in prepTracksSet {
                
                let track = _track as! Track
                
                // If track has not already been prepped, add a serial async task (to avoid concurrent prepping of the same track by two threads) to the trackPrepQueue
                
                // Async execution is important here, because reading from disk could be expensive and this info is not needed immediately.
                if (!track.preparedForPlayback) {
                    
                    let prepOp = BlockOperation(block: {
                        TrackIO.prepareForPlayback(track)
                    })
                    
                    trackPrepQueue.addOperation(prepOp)
                }
            }
        }
    }
    
    private func trackPlaybackCompleted() {
        
        // Stop playback of the old track
        stop()
        
        // Continue the playback sequence
        do {
            try subsequentTrack()
            
            // Notify the UI about this track change event
            EventRegistry.publishEvent(.trackChanged, TrackChangedEvent(getPlayingTrack()))
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                EventRegistry.publishEvent(.trackNotPlayed, TrackNotPlayedEvent(error as! InvalidTrackError))
            }
        }
    }
    
    func stop() {
        
        if (player.getPlaybackState() != .noTrack) {
            PlaybackSession.endCurrent()
            player.stop()
        }
    }
    
    func nextTrack() throws -> IndexedTrack? {
        let track = playlist.peekTrackAt(playbackSequence.next())
        try play(track)
        return track
    }
    
    func previousTrack() throws -> IndexedTrack? {
        let track = playlist.peekTrackAt(playbackSequence.previous())
        try play(track)
        return track
    }
    
    func getPlaybackState() -> PlaybackState {
        return player.getPlaybackState()
    }
    
    func getSeekPosition() -> (seconds: Double, percentage: Double) {
        
        let playingTrack = getPlayingTrack()
        let seconds = playingTrack != nil ? player.getSeekPosition() : 0
        let percentage = playingTrack != nil ? seconds * 100 / playingTrack!.track!.duration! : 0
        
        return (seconds, percentage)
    }
    
    func seekForward() {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track!.duration!
        
        let newPosn = min(trackDuration, curPosn + Double(preferences.seekLength))
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        if (newPosn < trackDuration) {
            
            let session = PlaybackSession.start(playingTrack!)
            player.seekToTime(session, newPosn)
            
        } else {
            trackPlaybackCompleted()
        }
    }
    
    func seekBackward() {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let curPosn = player.getSeekPosition()
        let newPosn = max(0, curPosn - Double(preferences.seekLength))
        
        let session = PlaybackSession.start(getPlayingTrack()!)
        player.seekToTime(session, newPosn)
    }
    
    func seekToPercentage(_ percentage: Double) {
        
        if (player.getPlaybackState() != .playing) {
            return
        }
        
        // Calculate the new start position
        let playingTrack = getPlayingTrack()
        let trackDuration = playingTrack!.track!.duration!
        
        let newPosn = percentage * trackDuration / 100
        
        // If this seek takes the track to its end, stop playback and proceed to the next track
        if (newPosn < trackDuration) {
            let session = PlaybackSession.start(playingTrack!)
            player.seekToTime(session, newPosn)
        } else {
            trackPlaybackCompleted()
        }
    }
    
    func getPlayingTrack() -> IndexedTrack? {
        return playlist.peekTrackAt(playbackSequence.getCursor())
    }
    
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequence.toggleRepeatMode()
    }
    
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
        return playbackSequence.toggleShuffleMode()
    }
    
    // Called when playback of the current track completes
    func consumeEvent(_ event: Event) {
        
        let _evt = event as! PlaybackCompletedEvent
        
        // Do not accept duplicate/old events
        if (PlaybackSession.isCurrent(_evt.session)) {
            trackPlaybackCompleted()
        }
    }
    
    func play(_ index: Int, _ interruptPlayback: Bool) throws -> IndexedTrack? {
    
        let playbackState = player.getPlaybackState()
        if (interruptPlayback || playbackState == .noTrack) {
            return try play(index)
        }
        
        return nil
    }
    
    func trackAdded() {
        prepareNextTracksForPlayback()
    }
    
    func trackRemoved(_ removedTrackIndex: Int) {
        if (playlist.size() > 0) {
            prepareNextTracksForPlayback()
        }
    }
    
    func trackReordered(_ oldIndex: Int, _ newIndex: Int) {
        prepareNextTracksForPlayback()
    }
    
    func playlistReordered(_ newCursor: Int?) {
        prepareNextTracksForPlayback()
    }
    
    func playlistCleared() {
    }
}