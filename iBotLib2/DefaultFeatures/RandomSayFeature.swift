//
//  RandomSayFeature.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

class RandomSayFeature: BotFeature
{
	override func work(str: String) -> Bool
	{
		let talkEngine = UserLocalTalkEngine()
		
		talkEngine.talk(message: str) { (res) in
			if let res = res
			{
				print("ResponsedWord: "+res)
				self.say(str: res, compProc: {})
			}
		}
		return true
	}
}
