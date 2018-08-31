//
//  SpeechRecognizer.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/29.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit
import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate
{
	private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
	private var recognitionRequest:SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask:SFSpeechRecognitionTask?
	private let audioEngine = AVAudioEngine()
	
	var recognizedWord:String?			// 認識したワード
	var isRunning = false				//
	
	private var speechEnabled = false	// 音声認識可能かどうか
	
	/* ------------------------------------------------------------------------------------
	* コンストラクタ
	------------------------------------------------------------------------------------ */
	override init()
	{
		super.init()
		
		self.speechRecognizer?.delegate = self
		
		SFSpeechRecognizer.requestAuthorization { (authStatus) in
			if (authStatus == SFSpeechRecognizerAuthorizationStatus.authorized)
			{
				self.speechEnabled = true
			}
		}
	}
	
	/* -----------------------------------------------------
	* 音声の聞き取りを開始する
	------------------------------------------------------ */
	func startRecoding()
	{
		if (self.isRunning)
		{
			return
		}
		
		self.refreshTask()
		self.isRunning = true
		
		let audioSession = AVAudioSession.sharedInstance()
		try? audioSession.setCategory(AVAudioSessionCategoryRecord)
		try? audioSession.setMode(AVAudioSessionModeMeasurement)
		try? audioSession.setActive(true, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
		
		self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		
		guard let inputNode:AVAudioInputNode = self.audioEngine.inputNode else { return }
		guard let recognitionRequest = self.recognitionRequest else { return }
		
		recognitionRequest.shouldReportPartialResults = true
		
		self.recognitionTask = self.speechRecognizer?.recognitionTask(
			with: recognitionRequest, resultHandler: { [weak self] (result, err) in
				guard let wself = self else { return }
				
				var isFinal = false
				if let r = result
				{
					wself.recognizedWord = r.bestTranscription.formattedString
					//					print(r.bestTranscription.formattedString)
					isFinal = r.isFinal
				}
				
				if (err != nil || isFinal)
				{
					wself.audioEngine.stop()
					inputNode.removeTap(onBus: 0)
				}
		})
		
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer, when) in
			self.recognitionRequest?.append(buffer)
		})
		
		self.startAudioEngine()
		
		print("音声認識を開始します")
	}
	
	/* -----------------------------------------------------
	* 音声の聞き取りを終了する
	------------------------------------------------------ */
	func stopRecoding()
	{
		if (self.audioEngine.isRunning)
		{
			self.audioEngine.stop()
			self.recognitionRequest?.endAudio()
			self.audioEngine.inputNode.removeTap(onBus: 0)
			
			self.isRunning = false
			
			print("音声認識を終了します")
		}
	}
	
	private func startAudioEngine()
	{
		self.audioEngine.prepare()
		if ((try? self.audioEngine.start()) == nil)
		{
			print("AudioEngine cannot start.")
		}
	}
	
	private func refreshTask()
	{
		self.recognizedWord = ""
		
		if let recognitionTask = self.recognitionTask
		{
			recognitionTask.cancel()
			self.recognitionTask = nil
		}
	}
	
	// MARK - SFSpeechRecognizer delegate methods
	
	func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool)
	{
	}
}
