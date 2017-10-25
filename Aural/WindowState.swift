import Cocoa

/**
 Provides convenient access to the state of the main window, across the app
 */
class WindowState {
    
    // MARK: WindowState Variables
    
    static var window: NSWindow?
    static var showingPlaylist: Bool = true
    static var showingEffects: Bool = true
    static var playlistDockState: PlaylistDockState = .none
    
    // MARK: WindowState Functions
    
    static func location() -> NSPoint {
        return window!.frame.origin
    }
    
    static func getPersistentState() -> UIState {
        
        let uiState = UIState()
        
        uiState.showEffects = WindowState.showingEffects
        uiState.showPlaylist = WindowState.showingPlaylist
        uiState.playlistDockState = WindowState.playlistDockState
        
        return uiState
    }
}
