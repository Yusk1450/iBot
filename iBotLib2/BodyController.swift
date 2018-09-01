//
//  BodyController.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/31.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

open class BodyController: NSObject
{
	public class func up()
	{
		BodyController.hand(left: 1.0, right: 1.0)
	}
	
	public class func middle()
	{
		BodyController.hand(left: 0.5, right: 0.5)
	}
	
	public class func down()
	{
		BodyController.hand(left: 0.0, right: 0.0)
	}
	
	public class func hand(left:Double, right:Double)
	{
		var data = "C".data(using: .ascii)
		data?.append(Data(bytes: [1, UInt8(left * 50.0), UInt8(right * 50.0), 255]))			// 種類,右手,左手（終端文字:255）

		if let data = data
		{
			BLEManager.shared.writeValue(data: data)
		}
	}
	
//	public class func shake()
//	{
//	}
}
