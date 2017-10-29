//
//  MenuController.swift
//  Aural
//
//  Created by Tobias Dunkel on 25.10.17.
//  Copyright © 2017 Anonymous. All rights reserved.
//

import Cocoa

enum StateMenuItems: NSString{
    case playlistMenuItem
    case effectsMenuItem
}

class MenuController: NSObject, NSMenuDelegate {
    
    lazy var mWC: MainWindowController = (NSApp.delegate as! AppDelegate).mainWindowController
    lazy var pWC: PlaylistWindowController = (NSApp.delegate as! AppDelegate).mainWindowController.playlistWindowController

    // MARK: - IBOutlets (only for menu Items which need to be changed, e.g. toggles)
    
    @IBOutlet weak var playlistMenuItem: NSMenuItem!
    @IBOutlet weak var effectsMenuItem: NSMenuItem!
    
    // MARK: - Functions
    
    /** changes the state of toggle menu Items */
    func changeMenuState(_ item: StateMenuItems, _ state: Bool?) {
        //print(#function)
        
        guard let enabled: Int = state?.hashValue else { return }
        
        switch item {
            
        case .playlistMenuItem:
            playlistMenuItem.state = NSControl.StateValue(rawValue: enabled)
            
        case .effectsMenuItem:
            effectsMenuItem.state = NSControl.StateValue(rawValue: enabled)

        }
        
    }
    
    // MARK: - IBActions
    
    // Playback Menu
    
    @IBAction func menuPlayPauseAction(_ sender: NSMenuItem) {
        mWC.playbackViewController.playPauseAction(sender)
    }
    
    // View Menu
    
    @IBAction func menuTogglePlaylistAction(_ sender: NSMenuItem) {
        mWC.togglePlaylistAction(sender)
    }
    
    @IBAction func menuToggleEffectsAction(_ sender: NSMenuItem) {
        mWC.toggleEffectsAction(sender)
    }
    
    @IBAction func menuDockPlaylistLeftAction(_ sender: NSMenuItem) {
        mWC.dockPlaylistLeftAction(sender)
    }
    
    @IBAction func menuDockPlaylistBottomAction(_ sender: NSMenuItem) {
        mWC.dockPlaylistBottomAction(sender)
    }
    
    @IBAction func menuDockPlaylistRightAction(_ sender: NSMenuItem) {
        mWC.dockPlaylistRightAction(sender)
    }
    
    @IBAction func menuMaximizePlaylistAction(_ sender: NSMenuItem) {
        pWC.maximizePlaylistAction(sender)
    }
    
    @IBAction func menuMaximizePlaylistVerticalAction(_ sender: NSMenuItem) {
        pWC.maximizePlaylistVerticalAction(sender)
    }
    
    @IBAction func menuMaximizePlaylistHorizontalAction(_ sender: NSMenuItem) {
        pWC.maximizePlaylistHorizontalAction(sender)
    }
    
    // Help Menu
    
    // Opens the online (HTML) user guide
    @IBAction func onlineUserGuideAction(_ sender: Any) {
        let workspace: NSWorkspace = NSWorkspace.shared
        workspace.open(AppConstants.onlineUserGuideURL)
    }
    
    // Opens the bundled (PDF) user guide
    @IBAction func pdfUserGuideAction(_ sender: Any) {
        let workspace: NSWorkspace = NSWorkspace.shared
        workspace.openFile(AppConstants.pdfUserGuidePath)
    }
    
}
