//
//  FeatureController.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

import UIKit

open class BotFeature: NSObject
{
	let priority:Int						// 優先順位
	var controller:BotFeatureController?
	
	public init(priority: Int)
	{
		self.priority = priority
	}
	
	open func work(str: String) -> Bool
	{
		// trueを返すと次のFeatureに進む、falseを返すとここで処理を終了する
		return true
	}
	
	public func say(str:String, compProc: @escaping () -> Void)
	{
		self.controller?.speechSynthesizer.say(str: str, compProc: compProc)
	}
}

public class BotFeatureController: NSObject
{
	private(set) var features = [BotFeature]()
	internal let speechSynthesizer = DefaultSynthesizer()
	
	/* -----------------------------------------------------
	* 機能を追加する
	------------------------------------------------------ */
	public func add(feature:BotFeature) -> Bool
	{
		feature.controller = self
		
		if (self.features.count <= 0)
		{
			self.features.append(feature)
		}
		else
		{
			// 小さい順に追加する
			for i in stride(from: 0, to: self.features.count, by: 1)
			{
				if (feature.priority < self.features[i].priority)
				{
					self.features.insert(feature, at: max(0, i-1))
				}
			}
		}
		print(self.features)
		
		return true
	}
	
	/* -----------------------------------------------------
	* 機能を実行する
	------------------------------------------------------ */
	public func start(str:String)
	{
		for i in stride(from: 0, to: self.features.count, by: 1)
		{
			if (!self.features[i].work(str: str))
			{
				break
			}
		}
	}
}
