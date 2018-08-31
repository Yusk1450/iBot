//
//  SpeechSynthesizer.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

class SpeechSynthesizer: NSObject
{
	public var sayCompProc:(() -> Void)?
	
	func say(str:String, compProc:@escaping () -> Void)
	{
	}
}
