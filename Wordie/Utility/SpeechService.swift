//
//  SpeechService.swift
//  Wordie
//
//  Created by William.Weng on 2026/6/10.
//

import Foundation
import AVFoundation

/// 單字發音服務 => 負責將英文單字轉成語音播放
final class SpeechService: NSObject, ObservableObject {
    
    static let shared = SpeechService()                 // 全域共用實例
    
    private let synthesizer = AVSpeechSynthesizer()     // 系統語音合成器
    
    override init() {
        super.init()
        try? configureAudioSession()
    }
}

// MARK: - 公開屬性
extension SpeechService {
    
    /// 是否已暫停
    var isPaused: Bool { synthesizer.isPaused }
}

// MARK: - 公開函式
extension SpeechService {

    /// 播放指定文字的語音
    /// - Parameters:
    ///   - text: 要念出的文字內容
    ///   - language: 語音語言代碼，例如 "en-US"、"en-GB"
    func speak(_ text: String, language: String) {
        
        let utterance = utteranceMaker(with: language, text: text)
        stop()
        synthesizer.speak(utterance)
    }
    
    /// 立刻或在單字結束後停止語音
    /// - Parameter boundary: 停止邊界，預設為 `.immediate`
    func stop(at boundary: AVSpeechBoundary = .immediate) {
        synthesizer.stopSpeaking(at: boundary)
    }
    
    /// 從暫停處繼續播放
    /// 如果目前語音尚未暫停，這個呼叫不會有作用。
    func resume() {
        synthesizer.continueSpeaking()
    }
    
    /// 暫停語音
    /// - Parameter boundary: 暫停邊界 (`.immediate`：立刻暫停 / `.word`：念完目前單字後暫停)
    func pause(at boundary: AVSpeechBoundary = .immediate) {
        synthesizer.pauseSpeaking(at: boundary)
    }
}

// MARK: - 小工具
private extension SpeechService {
        
    /// 設定音訊 session (.playback：允許播放音訊 / .spokenAudio：適合語音內容 / .defaultToSpeaker：預設從喇叭播放，而不是聽筒)
    func configureAudioSession() throws {
        
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.defaultToSpeaker])
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    /// 建立語音播報物件
    /// - Parameters:
    ///   - language: 語音語言代碼
    ///   - text: 要播報的文字
    /// - Returns: 設定完成的 `AVSpeechUtterance`
    func utteranceMaker(with language: String, text: String) -> AVSpeechUtterance {
        
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.05
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.05
        
        return utterance
    }
}
