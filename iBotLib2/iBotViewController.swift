//
//  iBotViewController.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/29.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

open class iBotViewController: UIViewController, OSCServerDelegate
{
	private let speechRecognizer = SpeechRecognizer()						// 音声認識
	private let speechSynthesizer = DefaultSynthesizer()					// 音声発声
	
	private(set) var faces:[String: [UIImage]] = [String: [UIImage]]() 		// 顔画像
	open var faceView:AnimationView?
	
	private var blinkTimer:Timer?											// 瞬きタイマー
	
	private var tapGestureRecognizer:UITapGestureRecognizer?				// タップジェスチャ
	private var doubleTapGestureRecognizer:UITapGestureRecognizer?			// ダブルタップジェスチャ
	
	open var featureController = BotFeatureController()
	
	private var oscServer = OSCServer(address: "", port: 3001)				// OSC
	
    override open func viewDidLoad()
	{
        super.viewDidLoad()
		
		// 顔
		self.setupFaces()
		self.faceView = AnimationView(frame: self.view.frame)
		self.view.addSubview(self.faceView!)
		
		self.changeFaceType(type: Face.FaceType.Normal)
		
		// 瞬きタイマー
		self.blinkTimer?.invalidate()
		self.blinkTimer = Timer.scheduledTimer(timeInterval: TimeInterval(arc4random() % 4 + 1),
											   target: self,
											   selector: #selector(self.blick),
											   userInfo: nil,
											   repeats: false)
		
		self.setupGestureRecognizer()
		self.setupFeatures()
		
		self.oscServer.delegate = self
		self.oscServer.start()
    }
	
	/* -----------------------------------------------------
	* iBot初期化（ハードウェアと連携する）
	------------------------------------------------------ */
	public func setupiBot(uuid:String)
	{
		iBotCore.shared.setup(uuid: uuid)
	}
	
	/* -----------------------------------------------------
	* iBotに発話させる
	------------------------------------------------------ */
	public func say(str:String)
	{
		self.speechSynthesizer.say(str: str, compProc: {})
	}
	
	/* -----------------------------------------------------
	* iBotに発話させる
	------------------------------------------------------ */
	public func say(str:String, comp: @escaping () -> Void)
	{
		self.speechSynthesizer.say(str: str, compProc: comp)
	}
	
	/* -----------------------------------------------------
	* 腕を動かす
	------------------------------------------------------ */
	public func moveArm(left:Double, right:Double) -> iBotViewController
	{
		BodyController.hand(left: left, right: right)
		return self
	}
	
	/* -----------------------------------------------------
	* 腕を動かす
	------------------------------------------------------ */
	public func moveArm(left:Double, right:Double, delay:Double) -> iBotViewController
	{
		DispatchQueue.main.asyncAfter(deadline: .now() + delay)
		{
			BodyController.hand(left: left, right: right)
		}
		
		return self
	}
	
	/* -----------------------------------------------------
	* iBotと会話する
	------------------------------------------------------ */
	public func talk(message:String)
	{
		self.featureController.start(str: message)
	}
	
	/* -----------------------------------------------------
	* 指定した顔タイプに変更する
	------------------------------------------------------ */
	public func changeFaceType(type:String)
	{
		if let faces = self.faces[type]
		{
			self.faceView?.images = faces
		}
	}
	
	/* -----------------------------------------------------
	* 指定した顔タイプに変更する
	------------------------------------------------------ */
	public func changeFaceType(type:Face.FaceType)
	{
		if let faces = self.faces[type.rawValue]
		{
			self.faceView?.images = faces
		}
	}
	
	/* -----------------------------------------------------
	* 顔タイプを追加する
	------------------------------------------------------ */
	public func addFaceType(images:[UIImage], type:String)
	{
		self.faces[type] = images
	}
	
	/* -----------------------------------------------------
	* 音声認識を開始する
	------------------------------------------------------ */
	public func startHearing()
	{
		if (!self.speechRecognizer.isRunning)
		{
			self.say(str: "なんですか？", comp: { [weak self] () in
				guard let wself = self else { return }
				
				wself.speechRecognizer.startRecoding()
				wself.changeFaceType(type: Face.FaceType.Hearing)
			})
		}
	}
	
	/* -----------------------------------------------------
	* 音声認識を停止する
	------------------------------------------------------ */
	public func stopHearing()
	{
		if (self.speechRecognizer.isRunning)
		{
			self.speechRecognizer.stopRecoding()
			self.changeFaceType(type: Face.FaceType.Normal)
			
			if let recognizedWord = self.speechRecognizer.recognizedWord
			{
				print("RecognizedWord: "+recognizedWord)
				
				if (recognizedWord == "")
				{
					self.say(str: "うまく聞き取れませんでした", comp: {})
				}
				else
				{
					self.talk(message: recognizedWord)
				}
			}
		}
	}
	
	/* -----------------------------------------------------
	* 波紋を表示する
	------------------------------------------------------ */
	public func showRipple(point:CGPoint)
	{
		guard let bundle = iBotCore.shared.getBundle() else
		{
			return
		}
		
		let imgSize = CGSize(width: 150.0, height: 150.0)
		var images = [UIImage]()
		for i in 1...23
		{
			if let img = UIImage(named: "touch-\(i)", in: bundle, compatibleWith: nil)
			{
				images.append(img)
			}
		}
		
		let ripple = AnimationView(frame: CGRect(
			x: point.x - imgSize.width/2,
			y: point.y - imgSize.height/2,
			width: imgSize.width,
			height: imgSize.height))
		ripple.images = images
		ripple.removeWhenAnimationFinished = true
		ripple.duration = 0.02;
		ripple.alpha = 0.7
		ripple.loopCount = 1
		
		self.view.addSubview(ripple)
		ripple.animation()
	}
}

extension iBotViewController
{
	// 顔セットアップ
	private func setupFaces()
	{
		if let images = Face.NormalFaceImages()
		{
			self.addFaceType(images: images, type: Face.FaceType.Normal.rawValue)
		}
		if let images = Face.HearingFaceImages()
		{
			self.addFaceType(images: images, type: Face.FaceType.Hearing.rawValue)
		}
	}
	
	// ジェスチャーセットアップ
	private func setupGestureRecognizer()
	{
		// ダブルタップ
		if let doubleTapGestureRecognizer = self.doubleTapGestureRecognizer
		{
			self.view.removeGestureRecognizer(doubleTapGestureRecognizer)
		}
		self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction(sender:)))
		self.doubleTapGestureRecognizer?.numberOfTapsRequired = 2
		self.view.addGestureRecognizer(self.doubleTapGestureRecognizer!)
		
		// シングルタップ
		if let tapGestureRecognizer = self.tapGestureRecognizer
		{
			self.view.removeGestureRecognizer(tapGestureRecognizer)
		}
		self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapAction(sender:)))
		self.tapGestureRecognizer?.numberOfTapsRequired = 1
		self.view.addGestureRecognizer(self.tapGestureRecognizer!)
	}
	
	// 初期機能セットアップ
	private func setupFeatures()
	{
		let randomSayFeature = RandomSayFeature(priority: 100)
		let _ = self.featureController.add(feature: randomSayFeature)
	}
}

extension iBotViewController
{
	// シングルタップ時の処理
	@objc private func singleTapAction(sender:AnyObject?)
	{
		guard let sender = sender as? UITapGestureRecognizer else
		{
			return
		}
		
		let point = sender.location(in: self.view)
		self.showRipple(point: point)
		
		// 音声認識を停止する
		self.stopHearing()
	}

	// ダブルタップ時の処理
	@objc private func doubleTapAction(sender:AnyObject?)
	{
		// 音声認識を開始する
		self.startHearing()
	}
}

extension iBotViewController
{
	// まばたき
	@objc private func blick()
	{
		if let faceView = self.faceView
		{
			if (!faceView.isAnimation)
			{
				faceView.animation()
			}
		}
		
		self.blinkTimer?.invalidate()
		self.blinkTimer = Timer.scheduledTimer(timeInterval: TimeInterval(arc4random() % 4 + 1),
											   target: self,
											   selector: #selector(self.blick),
											   userInfo: nil,
											   repeats: false)
	}
}

extension iBotViewController
{
	open override var prefersStatusBarHidden: Bool
	{
		return true
	}
}

extension iBotViewController
{
	public func didReceive(_ message: OSCMessage)
	{
		if let msg = message.arguments[0] as? String
		{
			print("RecognizedWord: "+msg)
			self.talk(message: msg)
		}
	}
}
