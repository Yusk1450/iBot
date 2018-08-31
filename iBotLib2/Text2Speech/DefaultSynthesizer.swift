//
//  DefaultSynthesizer.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit
import AVFoundation

class DefaultSynthesizer: SpeechSynthesizer, AVSpeechSynthesizerDelegate
{
	let talker = AVSpeechSynthesizer()
	
	override func say(str: String, compProc: @escaping () -> Void)
	{
		self.sayCompProc = compProc
		
		let audioSession = AVAudioSession.sharedInstance()
		try? audioSession.setCategory(AVAudioSessionCategoryAmbient)
		
		self.talker.delegate = self
		
		let utterance = AVSpeechUtterance(string: str)
		utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
		utterance.pitchMultiplier = 1.0
		
		self.talker.speak(utterance)
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
	{
		if let sayCompProc = self.sayCompProc
		{
			sayCompProc()
		}
	}
}
