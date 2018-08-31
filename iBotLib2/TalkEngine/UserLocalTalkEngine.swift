//
//  UserLocalTalkEngine.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

class UserLocalTalkEngine: NSObject
{
	static let sharedInstance = UserLocalTalkEngine()
	
	let apikey = "e5dd7826891a5dd31040"
	let baseURL = "https://chatbot-api.userlocal.jp/api/chat"
	
	func talk(message:String, response:@escaping (String?) -> Void)
	{
		if let message = message.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
		{
			let client = URLSessionClient()
			let query = [URLQueryItem(name: "message", value: message), URLQueryItem(name: "key", value: self.apikey)]
			client.get(url: baseURL, queryItems: query, comp: { (data) in
				if let data = data as? Data
				{
					do
					{
						if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
						{
							if let res = json["result"] as? String
							{
								response(res)
							}
						}
					}
					catch
					{
						print("Serialize Error")
					}
				}
			})
		}
	}
}
