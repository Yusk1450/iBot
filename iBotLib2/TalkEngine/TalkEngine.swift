//
//  TalkEngine.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

protocol TalkEngine: class
{
	func talk(message:String, response:@escaping (String?) -> Void)
}
