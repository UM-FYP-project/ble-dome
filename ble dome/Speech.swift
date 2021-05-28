//
//  Speech.swift
//  ble dome
//
//  Created by UM on 26/05/2021.
//

import Foundation
import AVFoundation
//func Speech(_ Str : String){
//    let speech = AVSpeechUtterance(string: Str)
//    let voice = AVSpeechSynthesisVoice(language: "en-GB")
//    speech.voice = voice
//    let Synthesis = AVSpeechSynthesizer()
//    if !Synthesis.isSpeaking{
//        Synthesis.speak(speech)
//    }
//}

class Speech: NSObject, ObservableObject{
    let voice = AVSpeechSynthesisVoice(language: "en-GB")
    let Synthesis = AVSpeechSynthesizer()
    @Published var isFinish = true
//
//    func initSpeech(){
//        print("Speech init")
//        Synthesis.delegate = self
//    }
    
    override init() {
            super.init()
            Synthesis.delegate = self
    }
    
    func Say(_ Str : String){
        let speech = AVSpeechUtterance(string: Str)
        speech.voice = voice
        Synthesis.speak(speech)
    }
    
    func Stop(){
        Synthesis.stopSpeaking(at: .immediate)
    }
    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
//        print("Speech Continue")
//        self.isFinish = false
//    }
    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
//        print("Speech is Finish")
//        self.isFinish = true
//    }
}

extension Speech: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speech is Finished")
        self.isFinish = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Speech is Started")
        self.isFinish = false
    }
}
