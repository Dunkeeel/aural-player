/*
    Encapsulates all application state, with values that are marshaled into a format directly usable by the UI, based on user preferences.
 */

import Foundation

class UIAppState {
    
    // MARK: - Variables
    
    var playlistHidden: Bool
    var effectsHidden: Bool
    var playlistDockState: PlaylistDockState
    
//    var windowLocation: NSPoint
    
    var repeatMode: RepeatMode
    var shuffleMode: ShuffleMode
    
    var volume: Float
    var muted: Bool
    var balance: Float
    
    var eqGlobalGain: Float
    var eqBands: [Int: Float] = [Int: Float]()
    
    var pitchBypass: Bool
    var pitch: Float
    var pitchOverlap: Float
    
    var formattedPitch: String
    var formattedPitchOverlap: String
    
    var timeBypass: Bool
    var timeStretchRate: Float
    var timeOverlap: Float
    
    var formattedTimeStretchRate: String
    var formattedTimeOverlap: String
    
    var seekTimerInterval: Int
    
    var reverbBypass: Bool
    var reverbPreset: String
    var reverbAmount: Float
    
    var formattedReverbAmount: String
    
    var delayBypass: Bool
    var delayAmount: Float
    var delayTime: Double
    var delayFeedback: Float
    var delayLowPassCutoff: Float
    
    var formattedDelayAmount: String
    var formattedDelayTime: String
    var formattedDelayFeedback: String
    var formattedDelayLowPassCutoff: String
    
    var filterBypass: Bool
    var filterBassMin: Double
    var filterBassMax: Double
    var filterMidMin: Double
    var filterMidMax: Double
    var filterTrebleMin: Double
    var filterTrebleMax: Double
    
    var formattedFilterBassRange: String
    var formattedFilterMidRange: String
    var formattedFilterTrebleRange: String
    
    //MARK: - Initializer
    
    init(_ appState: AppState, _ preferences: Preferences) {
        
        if (preferences.viewOnStartup.option == .rememberFromLastAppLaunch) {
            
            self.playlistHidden = !appState.uiState.showPlaylist
            self.effectsHidden = !appState.uiState.showEffects
            self.playlistDockState = appState.uiState.playlistDockState
            
        } else {
            
            let viewType = preferences.viewOnStartup.viewType
            self.playlistHidden = viewType == .effectsOnly || viewType == .compact
            self.effectsHidden = viewType == .playlistOnly || viewType == .compact
            self.playlistDockState = .bottom
        }
        
        self.repeatMode = appState.playbackSequenceState.repeatMode
        self.shuffleMode = appState.playbackSequenceState.shuffleMode
        
        let playerState = appState.audioGraphState
        
        if (preferences.volumeOnStartup == .rememberFromLastAppLaunch) {
            self.volume = round(playerState.volume * AppConstants.volumeConversion_audioGraphToUI)
            self.muted = playerState.muted
        } else {
            self.volume = round(preferences.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI)
            self.muted = false
        }
        
        self.balance = round(playerState.balance * AppConstants.panConversion_audioGraphToUI)
        
        self.eqGlobalGain = playerState.eqGlobalGain
        for (freq,gain) in playerState.eqBands {
            self.eqBands[freq] = gain
        }
        
        self.pitchBypass = playerState.pitchBypass
        self.pitch = playerState.pitch * AppConstants.pitchConversion_audioGraphToUI
        self.pitchOverlap = playerState.pitchOverlap
        
        self.formattedPitch = ValueFormatter.formatPitch(self.pitch)
        self.formattedPitchOverlap = ValueFormatter.formatOverlap(playerState.pitchOverlap)
        
        self.timeBypass = playerState.timeBypass
        self.timeStretchRate = playerState.timeStretchRate
        self.timeOverlap = playerState.timeOverlap
        
        self.formattedTimeStretchRate = ValueFormatter.formatTimeStretchRate(playerState.timeStretchRate)
        self.formattedTimeOverlap = ValueFormatter.formatOverlap(playerState.timeOverlap)
        
        self.seekTimerInterval = playerState.timeBypass ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * playerState.timeStretchRate))
        
        self.reverbBypass = playerState.reverbBypass
        self.reverbPreset = playerState.reverbPreset.description
        self.reverbAmount = playerState.reverbAmount
        
        self.formattedReverbAmount = ValueFormatter.formatReverbAmount(playerState.reverbAmount)
        
        self.delayBypass = playerState.delayBypass
        self.delayTime = playerState.delayTime
        self.delayAmount = playerState.delayAmount
        self.delayFeedback = playerState.delayFeedback
        self.delayLowPassCutoff = playerState.delayLowPassCutoff
        
        self.formattedDelayTime = ValueFormatter.formatDelayTime(playerState.delayTime)
        self.formattedDelayAmount = ValueFormatter.formatDelayAmount(playerState.delayAmount)
        self.formattedDelayFeedback = ValueFormatter.formatDelayFeedback(playerState.delayFeedback)
        self.formattedDelayLowPassCutoff = ValueFormatter.formatDelayLowPassCutoff(playerState.delayLowPassCutoff)
         
        self.filterBypass = playerState.filterBypass
        self.filterBassMin = Double(playerState.filterBassMin)
        self.filterBassMax = Double(playerState.filterBassMax)
        self.filterMidMin = Double(playerState.filterMidMin)
        self.filterMidMax = Double(playerState.filterMidMax)
        self.filterTrebleMin = Double(playerState.filterTrebleMin)
        self.filterTrebleMax = Double(playerState.filterTrebleMax)
        
        self.formattedFilterBassRange = ValueFormatter.formatFilterFrequencyRange(playerState.filterBassMin, playerState.filterBassMax)
        self.formattedFilterMidRange = ValueFormatter.formatFilterFrequencyRange(playerState.filterMidMin, playerState.filterMidMax)
        self.formattedFilterTrebleRange = ValueFormatter.formatFilterFrequencyRange(playerState.filterTrebleMin, playerState.filterTrebleMax)
    }
}
