//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Erik Uecke on 5/5/17.
//  Copyright © 2017 Erik Uecke. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }

    
    func recUIViewStates(recEnabled: Bool, stopRecEnabled: Bool, recText: String) {
        recordButton.isEnabled = recEnabled
        stopRecordingButton.isEnabled = stopRecEnabled
        recordingLabel.text = recText
    }
    
    enum RecordState {
        case isRecording
        case notRecording
    }
    
    func recordButtonsState(isOrNotRecording state: RecordState) {
        switch state {
        case .isRecording:
            recUIViewStates(recEnabled: false, stopRecEnabled: true, recText: "Recording In Progress")
        case .notRecording:
            recUIViewStates(recEnabled: true, stopRecEnabled: false, recText: "Tap To Record")
        }
    }


    @IBAction func recordAudio(_ sender: Any) {
        recordButtonsState(isOrNotRecording: .isRecording)
        
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()

        
    }

    @IBAction func stopRecording(_ sender: Any) {
        recordButtonsState(isOrNotRecording: .notRecording)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

// Extension for AVAudioRecorderDelegate

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
}

