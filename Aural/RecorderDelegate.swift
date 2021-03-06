/*
    Concrete implementation of RecorderDelegateProtocol
 */

import Foundation

class RecorderDelegate: RecorderDelegateProtocol {
    
    private var recorder: RecorderProtocol
    
    init(_ recorder: RecorderProtocol) {
        self.recorder = recorder
    }
    
    func startRecording(_ format: RecordingFormat) {
        recorder.startRecording(format)
    }
    
    func stopRecording() {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.stopRecording()
        }
    }
    
    func saveRecording(_ url: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.saveRecording(url)
        }
    }
    
    func deleteRecording() {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            self.recorder.deleteRecording()
        }
    }
    
    func getRecordingInfo() -> RecordingInfo? {
        return recorder.getRecordingInfo()
    }
    
    func isRecording() -> Bool{
        return recorder.isRecording()
    }
}
