//
//  AnimationView.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

public class AnimationView: UIImageView
{
	private var timer:Timer?
	var duration = 0.05								// アニメーション切り替え速度
	var loopCount = 1								// ループカウント
	var removeWhenAnimationFinished = false			// アニメーション終了時にビューを取り除く
	private(set) var isAnimation = false

	var _images:[UIImage] = [UIImage]()				// アニメーション画像
	var images:[UIImage]
	{
		get
		{
			return self._images
		}
		set
		{
			self.disposeTimer()
			self._images = newValue
			self.currentImageIndex = 0
			
			if (self.isAnimation)
			{
				self.animation()
			}
		}
	}
	
	var _currentImageIndex:Int = 0					// 現在の画像インデックス
	var currentImageIndex:Int
	{
		get
		{
			return self._currentImageIndex
		}
		set
		{
			if (newValue >= 0 && newValue <= self.images.count-1)
			{
				self.image = self.images[newValue]
				self._currentImageIndex = newValue
			}
		}
	}
	
	deinit
	{
		self.disposeTimer()
	}
	
	public func animation()
	{
		self.disposeTimer()
		
		self.isAnimation = true
		self.timer = Timer.scheduledTimer(
			timeInterval: self.duration, target: self, selector: #selector(self.nextImage), userInfo: nil, repeats: true)
	}
	
	@objc private func nextImage()
	{
		if (self.currentImageIndex < self.images.count - 1)
		{
			self.currentImageIndex += 1
		}
		else
		{
			self.currentImageIndex = 0
			self.loopCount -= 1
			
			if (self.loopCount <= 0)
			{
				self.disposeTimer()
				
				if (self.removeWhenAnimationFinished)
				{
					self.removeFromSuperview()
				}
			}
		}
	}
	
	private func disposeTimer()
	{
		self.timer?.invalidate()
		self.timer = nil
		
		self.isAnimation = false
	}
}
