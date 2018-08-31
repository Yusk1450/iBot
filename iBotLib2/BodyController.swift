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
		let bleManager = BLEManager.shared
//		bleManager.writeValue(data: <#T##Data#>)
	}
	
	public class func shake()
	{
		let bleManager = BLEManager.shared
//		bleManager.writeValue(data: <#T##Data#>)
	}
}
