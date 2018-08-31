//
//  Face.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

public class Face: NSObject
{
	public enum FaceType:String
	{
		case Normal = "Normal"
		case Hearing = "Hearing"
	}
	
	class func NormalFaceImages() -> [UIImage]?
	{
		if let bundle = iBotCore.shared.getBundle()
		{
			return [
				UIImage(named: "kao-01", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-02", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-03", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-04", in: bundle, compatibleWith: nil)!
			]
		}
		
		return nil
	}
	
	class func HearingFaceImages() -> [UIImage]?
	{
		if let bundle = iBotCore.shared.getBundle()
		{
			return [
				UIImage(named: "kao-red-01", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-red-02", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-red-03", in: bundle, compatibleWith: nil)!,
				UIImage(named: "kao-red-04", in: bundle, compatibleWith: nil)!
			]
		}
		
		return nil
	}
}
