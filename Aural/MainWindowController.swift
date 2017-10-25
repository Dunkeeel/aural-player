import Cocoa

/** All possible dock states of the playlist window, in relation to the main window */
enum PlaylistDockState: String {
    case bottom
    case right
    case left
    case none
}

/** All possible dock types */
enum DockType: String {
    case bottom
    case right
    case left
}

/**
 View controller for all app windows - main window and playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of the windows and their constituent views.
 */
class MainWindowController: NSWindowController, NSWindowDelegate {
    
    // MARK: - IBOutlets
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Acts as a parent for the playlist window. Not manually resizable. Changes size when toggling playlist/effects views.
    @IBOutlet weak var mainWindow: NSWindow!
    
    // Detachable/movable/resizable window that contains the playlist view. Child of the main window.
    @IBOutlet weak var playlistWindow: NSWindow!
    //var playlistWindow = AppDelegat
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    // Menu items to toggle the playlist and effects views
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // The box that encloses the effects panel
    @IBOutlet weak var fxBox: NSBox!
    
    // The stack view that inherits the main ui panels
    @IBOutlet weak var stackView: NSStackView!
    
    
    // MARK: - IBActions
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    @IBAction func dockPlaylistRightAction(_ sender: AnyObject) {
        dockPlaylist(.right)
    }
    
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        dockPlaylist(.left)
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        dockPlaylist(.bottom)
    }
    
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        maximizePlaylist()
    }
    
    @IBAction func maximizePlaylistHorizontalAction(_ sender: AnyObject) {
        maximizePlaylist(true, false)
    }
    
    @IBAction func maximizePlaylistVerticalAction(_ sender: AnyObject) {
        maximizePlaylist(false, true)
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(true)
    }

    @IBAction func quitAuralAction(_ sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func hideAuralAction(_ sender: AnyObject) {
        NSApplication.shared.hide(Any?.self)
    }
    
    // MARK: - Variables
    
    // Remembers if/where the playlist window has been docked with the main window
    private var playlistDockState: PlaylistDockState = .none
    
    // Flag to indicate that a window move/resize operation was initiated by the app (as opposed to by the user)
    private var automatedPlaylistMoveOrResize: Bool = false
    
    // Remembers the relationship (in terms of location co-ordinates) of the playlist window to the main window
    private var playlistWindowOffset: CGPoint?
    
    // Convenient accessor to the screen object
    private let screen: NSScreen = NSScreen.main!
    
    // Convenient accessor to the screen's width
    private var screenWidth: CGFloat = {
        return NSScreen.main!.frame.width
    }()
    
    // Convenient accessor to the screen's height
    private var screenHeight: CGFloat = {
        return NSScreen.main!.frame.height
    }()
    
    // MARK: - Functions
    override func windowDidLoad() {
        super.windowDidLoad()
        WindowState.window = self.mainWindow
        print(playlistWindow.debugDescription)
        //mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.below)
        //setUpWindows()
    }
    
    func setUpWindows() {
        // restore the windows state
        
        let appState = ObjectGraph.getUIAppState()
        playlistDockState = appState.playlistDockState
        
        // set up main window
        
        //mainWindow.styleMask.insert(.fullSizeContentView)
        mainWindow.hasShadow = false
        mainWindow.titlebarAppearsTransparent = true
        mainWindow.standardWindowButton(NSWindow.ButtonType.closeButton)?.isHidden = false
        mainWindow.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = false
        mainWindow.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
        mainWindow.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false
        
        mainWindow.windowController?.windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: "mainWindow")
        mainWindow.windowController?.shouldCascadeWindows = false
        //mainWindow.setFrameUsingName(NSWindow.FrameAutosaveName(rawValue: "mainWindow"))
        
        mainWindow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        mainWindow.isMovableByWindowBackground = false
        mainWindow.makeKeyAndOrderFront(self)
        
        
        // set up playlist window
        
        //playlistWindow.styleMask.insert(.fullSizeContentView)
        playlistWindow.hasShadow = false
        playlistWindow.titlebarAppearsTransparent = true
        playlistWindow.standardWindowButton(NSWindow.ButtonType.closeButton)?.isHidden = false
        playlistWindow.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
        playlistWindow.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
        
        //playlistWindow.delegate = self
        
        playlistWindow.windowController?.windowFrameAutosaveName = NSWindow.FrameAutosaveName(rawValue: "playlistWindow")
        playlistWindow.windowController?.shouldCascadeWindows = false
        //playlistWindow.setFrameUsingName(NSWindow.FrameAutosaveName(rawValue: "playlistWindow"))
        
        //
        //playlistWindow.makeKeyAndOrderFront(self)
        
        playlistWindow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        playlistWindow.isMovableByWindowBackground = true
        
        print("\(#function) -> check playlistHidden")
        if (appState.playlistHidden) {
            hidePlaylist()
            //dockPlaylist(.bottom)
            // TODO: Make this configurable in preferences
            // Whenever the playlist is shown in the future, dock it at the bottom
        } else {
            showPlaylist()
            //dockPlaylist(.bottom)
        }
        
        if (playlistDockState != .none) {
            dockPlaylist(DockType(rawValue: playlistDockState.rawValue)!, false)
        }
        
        print("\(#function) -> check effectsHidden")
        if (appState.effectsHidden) {
            toggleEffects()
        }
    }
    
    func moveForDockedPlaylist() {
        
        switch playlistDockState {
            
        case .bottom:
                if mainWindow.frame.origin.y < self.screen.visibleFrame.origin.y + min(playlistWindow.height, mainWindow.remainingHeight) + UIConstants.windowGap{
                    
                    mainWindow.setFrameOrigin(CGPoint(x: mainWindow.frame.origin.x,y: self.screen.visibleFrame.origin.y + min(playlistWindow.height, mainWindow.remainingHeight) + UIConstants.windowGap))
                }
            
        case .left:
                if mainWindow.frame.origin.x < self.screen.visibleFrame.origin.x + min(playlistWindow.width, mainWindow.remainingWidth) + UIConstants.windowGap{
                    
                    mainWindow.setFrame(NSRect(origin: mainWindow.frame.origin, size: NSSize(width: min(mainWindow.width, self.screen.visibleFrame.width - 38), height: mainWindow.height)), display: true)
                    
                    mainWindow.setFrameOrigin(CGPoint(x: self.screen.visibleFrame.origin.x + min(playlistWindow.width, mainWindow.remainingWidth) + UIConstants.windowGap,y: mainWindow.frame.origin.y))
                }
            
        case .right:
                if mainWindow.frame.origin.x + mainWindow.width > self.screen.visibleFrame.origin.x + self.screen.visibleFrame.width - min(playlistWindow.width, mainWindow.remainingWidth) - UIConstants.windowGap{
                    
                    mainWindow.setFrame(NSRect(origin: mainWindow.frame.origin, size: NSSize(width: min(mainWindow.width, self.screen.visibleFrame.width - 38), height: mainWindow.height)), display: true)
                    
                    mainWindow.setFrameOrigin(CGPoint(x: self.screen.frame.width - mainWindow.width - min(playlistWindow.width + UIConstants.windowGap, mainWindow.remainingWidth),y: mainWindow.frame.origin.y))
                }
            
        default:
            return
        }
        
    }
    
    func windowDidResize(_ notification: Notification) {
        if (automatedPlaylistMoveOrResize && playlistDockState == .bottom){
            snapToBottom(window: playlistWindow, target: mainWindow, gap: UIConstants.windowGap)
        }
        
        // Only update docking state if playlist is docked and moved by hand
        if (!(playlistDockState == .none) && !automatedPlaylistMoveOrResize) {
            updatePlaylistWindowDockState()
        }
        
    }
    
    func windowDidMove(_ notification: Notification) {
        // Only update docking state if playlist window is moved by hand
        if (playlistWindow.frame.contains(NSEvent.mouseLocation) && !automatedPlaylistMoveOrResize) {
            updatePlaylistWindowDockState()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        hidePlaylist()
    }
    
    // MARK: - Private Functions
    
    // docks the playlist to the main window according to the type (.bottom, .right, .left)
    private func dockPlaylist(_ type: DockType, _ resize: Bool = true) {
        
        var playlistFrame = playlistWindow.frame
        
        automatedPlaylistMoveOrResize = true
        
        switch type {
            
        case .bottom :
            playlistDockState = .bottom
            moveForDockedPlaylist()
            
            if resize{
                playlistFrame.size = NSMakeSize(mainWindow.width, min(playlistWindow.height, (mainWindow.remainingHeight - UIConstants.windowGap)))
                playlistWindow.setFrame(playlistFrame, display: true, animate: false)
            }
            playlistWindow.setFrameTopLeftPoint(mainWindow.frame.origin
                .applying(CGAffineTransform.init(translationX: 0, y: -UIConstants.windowGap)))
            
        case .right :
            playlistDockState = .right
            moveForDockedPlaylist()
            
            if resize {
                playlistFrame.size = NSMakeSize(min(playlistWindow.width, mainWindow.remainingWidth - UIConstants.windowGap), mainWindow.height)
                playlistWindow.setFrame(playlistFrame, display: true, animate: false)
            }
            
            playlistWindow.setFrameOrigin(mainWindow.frame.origin
                .applying(CGAffineTransform.init(translationX: (mainWindow.width + UIConstants.windowGap), y: 0)))
            
            
            
        case .left :
            playlistDockState = .left
            moveForDockedPlaylist()
            
            if resize {
                playlistFrame.size = NSMakeSize(min(playlistWindow.width, mainWindow.remainingWidth - UIConstants.windowGap), mainWindow.height)
                playlistWindow.setFrame(playlistFrame, display: true, animate: false)
            }
            
            playlistWindow.setFrameOrigin(mainWindow.frame.origin
                .applying(CGAffineTransform.init(translationX: -(playlistWindow.width + UIConstants.windowGap), y: 0)))
            
            
        }
        
        automatedPlaylistMoveOrResize = false
        WindowState.playlistDockState = playlistDockState
    }
    
    // repositions the playlist at the bottom of the main window (without docking it)
    private func snapToBottom(window: NSWindow, target: NSWindow, gap: CGFloat = 0) {
        
        automatedPlaylistMoveOrResize = true
        playlistWindow.setFrameTopLeftPoint(NSPoint(x: window.x, y: (target.y - gap)))
        automatedPlaylistMoveOrResize = false
    }
    
    // maximizes the playlist related the position of the main window according to the specified flags
    private func maximizePlaylist(_ horizontal: Bool = true, _ vertical: Bool = true) {
    
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        var playlistFrame = playlistWindow.frame
        var playlistWidth: CGFloat, playlistHeight: CGFloat
        var playlistX: CGFloat, playlistY: CGFloat
        
        let mainWindowX: CGFloat = mainWindow.x
        let mainWindowY: CGFloat = mainWindow.y
        
        // Calculate new position and size of playlist window, in relation to the main window, depending on current dock state
        
        switch playlistDockState {
        
        case .bottom:
            
            playlistWidth = screenWidth
            playlistHeight = mainWindowY - UIConstants.windowGap
            playlistX = 0
            playlistY = 0
            
        case .right:
            
            playlistWidth = screenWidth - (mainWindowX + mainWindow.width)
            playlistHeight = screenHeight
            playlistX = playlistWindow.x
            playlistY = 0
            
        case .left:
            
            playlistWidth = mainWindowX
            playlistHeight = screenHeight
            playlistX = 0
            playlistY = 0
            
        case .none:
            
            // When the playlist is not docked, vertical maximizing will take preference over horizontal maximizing (i.e. portrait orientation)
            playlistWidth = playlistWindow.width
            playlistHeight = playlistWindow.height
            playlistX = playlistWindow.x
            playlistY = playlistWindow.y
            
            // These variables will determine the bounds of the new playlist window frame
            var minX: CGFloat = 0, minY: CGFloat = 0, maxX: CGFloat = screenWidth, maxY: CGFloat = screenHeight
            
            // Figure out where the playlist window is, in relation to the main window
            if ((playlistX + playlistWidth) < mainWindowX) {
                
                // Entire playlist window is to the left of the main window. Maximize to the left of the main window.
                maxX = mainWindowX - UIConstants.windowGap
                
            } else if (playlistX > mainWindowX + mainWindow.width) {
                
                // Entire playlist window is to the right of the main window. Maximize to the right of the main window.
                minX = mainWindowX + mainWindow.width + UIConstants.windowGap
                
            } else if ((playlistY + playlistHeight) < mainWindowY) {
                
                // Entire playlist window is below the main window. Maximize below the main window.
                maxY = mainWindowY - UIConstants.windowGap
                
            } else if (playlistY > (mainWindowY + mainWindow.height)) {
                
                // Entire playlist window is above the main window. Maximize above the main window.
                minY = mainWindowY + mainWindow.height + UIConstants.windowGap
                
            } else if (playlistX < mainWindowX) {
                
                // Left edge of playlist window is to the left of the left edge of the main window, and the 2 windows overlap. Maximize to the left of the main window.
                maxX = mainWindowX - UIConstants.windowGap
                
            } else if (playlistX > mainWindowX) {
                
                // Left edge of playlist window is to the right of the left edge of the main window, and the 2 windows overlap. Maximize to the right of the main window.
                minX = mainWindowX + mainWindow.width + UIConstants.windowGap
            }
            
            playlistX = minX
            playlistY = minY
            playlistWidth = maxX - minX
            playlistHeight = maxY - minY
        }
        
        if (horizontal && vertical) {
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistHeight)
        } else if (horizontal) {
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistWindow.y)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistWindow.height)
        } else {
            // Vertical only
            playlistFrame.origin = NSPoint(x: playlistWindow.x, y: playlistY)
            playlistFrame.size = NSMakeSize(playlistWindow.width, playlistHeight)
        }
        
        // Maximize the playlist window, within the visible frame of the screen (i.e. don't overlap with menu bar or dock)
        playlistWindow.setFrame(playlistFrame.intersection(screen.visibleFrame), display: true, animate: false)
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    private func togglePlaylist() {
        
        if (!playlistWindow.isVisible) {
            showPlaylist()
        } else {
            hidePlaylist()
        }
    }
    
    private func showPlaylist() {
        
        // Show playlist window and update UI controls
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.state = NSControl.StateValue(rawValue: 1)
        btnTogglePlaylist.image = UIConstants.imgPlaylistOn
        viewPlaylistMenuItem.state = NSControl.StateValue(rawValue: 1)
        WindowState.showingPlaylist = true
        
        // Re-dock the playlist window, as per the dock state
//        if (playlistDockState != .none) {
//            dockPlaylist(DockType(rawValue: playlistDockState.rawValue)!)
//        }
    }
    
    private func hidePlaylist(_ noteOffset: Bool = true) {
        
        // Hide playlist window and update UI controls
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = NSControl.StateValue(rawValue: 0)
        btnTogglePlaylist.image = UIConstants.imgPlaylistOff
        viewPlaylistMenuItem.state = NSControl.StateValue(rawValue: 0)
        WindowState.showingPlaylist = false
    }
    
    private func toggleEffects(_ animate: Bool = false) {
        
        if (fxBox.isHidden) {
            
            // Show effects view and update UI controls
            fxBox.isHidden = false
            btnToggleEffects.state = NSControl.StateValue(rawValue: 1)
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = NSControl.StateValue(rawValue: 1)
            WindowState.showingEffects = true
            
            realignPlaylist(fxPanelHidden: false)
            
        } else {
            
            // Hide effects view and update UI controls
            fxBox.isHidden = true
            btnToggleEffects.state = NSControl.StateValue(rawValue: 0)
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = NSControl.StateValue(rawValue: 0)
            WindowState.showingEffects = false
            
            realignPlaylist(fxPanelHidden: true)
        }
        print("called toggleEffects -> shown: \(String(WindowState.showingEffects)))")
    }
    
    private func realignPlaylist(fxPanelHidden: Bool){
        let alignY: CGFloat = fxBox.fittingSize.height + stackView.spacing
        
        if (playlistWindow.isVisible && playlistDockState == .bottom) {
            playlistWindow.setFrameOrigin(playlistWindow.frame.origin.applying(CGAffineTransform.init(translationX: 0, y: fxPanelHidden ? alignY : -alignY)))
        }
        print("called realign playlist")
    }
    
    // This method checks the position of the playlist window after the resize operation, and invalidates the playlist window's dock state if necessary.
    private func updatePlaylistWindowDockState() {
        
        if (playlistDockState == .bottom) {
            
            // Check if playlist window's top edge is adjacent to main window's bottom edge
            if ((playlistWindow.y + playlistWindow.height) != (mainWindow.y - UIConstants.windowGap)) {
                playlistDockState = .none
                WindowState.playlistDockState = .none
            }
            
        } else if (playlistDockState == .right) {
            
            // Check if playlist window's left edge is adjacent to main window's right edge
            if ((mainWindow.x + mainWindow.width + UIConstants.windowGap) != playlistWindow.x) {
                playlistDockState = .none
                WindowState.playlistDockState = .none

            }
            
        } else if (playlistDockState == .left) {
            
            // Check if playlist window's right edge is adjacent to main window's left edge
            if ((playlistWindow.x + playlistWindow.width) != (mainWindow.x - UIConstants.windowGap)) {
                playlistDockState = .none
                WindowState.playlistDockState = .none

            }
        }
    }
}
