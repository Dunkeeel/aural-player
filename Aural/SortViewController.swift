/*
    View controller for the playlist sort modal dialog
 */

import Cocoa

class SortViewController: NSViewController, PopoverViewDelegateProtocol {
    
    // The actual popover that is shown
    private var popover: NSPopover?
    
    // The view relative to which the popover is shown
    private var relativeToView: NSView?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    private let preferredEdge = NSRectEdge.minY

    // Playlist sort modal dialog fields
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    //@IBOutlet weak var playlistView: NSTableView!
    //@IBOutlet weak var btnSort: NSButton!
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
    }
    
    static func create(_ relativeToView: NSView) -> PopoverViewDelegateProtocol {
        
        let controller = SortViewController(nibName: SortViewController().nibName, bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        controller.relativeToView = relativeToView
        
        return controller
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        // Don't bother refreshing if not shown
        if (isShown()) {

        }
    }
    
    func show() {
        
        if (!popover!.isShown) {
            popover!.show(relativeTo: positioningRect, of: relativeToView!, preferredEdge: preferredEdge)
        }
    }
    
    func isShown() -> Bool {
        return popover!.isShown
    }
    
    func close() {
        
        if (popover!.isShown) {
            popover!.performClose(self)
        }
    }
    
    func toggle() {
        
        if (popover!.isShown) {
            close()
        } else {
            show()
        }
    }
    
    // MARK: - IBActions
    
//    @IBAction func sortPlaylistAction(_ sender: Any) {
//        print("\(#function) -> toggle sort popover")
//        
//        // Don't do anything if either no tracks or only 1 track in playlist
//        if (playlistView.numberOfRows < 2) {
//            return
//        }
//        
//        sortPopoverView.toggle()
//        //UIUtils.showModalDialog()
//    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state.rawValue == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state.rawValue == 1 ? SortOrder.ascending : SortOrder.descending
        
        // Perform the sort
        playlist.sort(sortOptions)
        //close()
        //UIUtils.dismissModalDialog()
        
        // Update the UI
        SyncMessenger.publishNotification(SortTracksNotification.instance)
        //playlistView.reloadData()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        //UIUtils.dismissModalDialog()
        close()
    }
}
