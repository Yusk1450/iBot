//
//  URLSessionClient.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/30.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit

open class URLSessionClient: NSObject
{
	/* -----------------------------------------------
	* GETリクエスト
	----------------------------------------------- */
	public func get(url urlString:String, queryItems: [URLQueryItem]?, comp:@escaping (Any) -> Void)
	{
		var components = URLComponents(string: urlString)
		components?.queryItems = queryItems
		
		let url = components?.url
		let task = URLSession.shared.dataTask(with: url!) { (data, response, err) in
			if let data = data
			{
				comp(data)
			}
			else
			{
				print(err ?? "Error")
			}
		}
		
		task.resume()
	}
	
	/* -----------------------------------------------
	* POSTリクエスト
	----------------------------------------------- */
	public func post(url urlString:String, parameters:[String: Any], comp:@escaping (Any) -> Void)
	{
		let url = URL(string: urlString)
		var request = URLRequest(url: url!)
		request.httpMethod = "POST"
		
		let parametersString: String = parameters.enumerated().reduce("") { (input, tuple) -> String in
			switch tuple.element.value
			{
			case let int as Int: return input + tuple.element.key + "=" + String(int) + (parameters.count - 1 > tuple.offset ? "&" : "")
			case let string as String: return input + tuple.element.key + "=" + string + (parameters.count - 1 > tuple.offset ? "&" : "")
			default: return input
			}
		}
		
		request.httpBody = parametersString.data(using: String.Encoding.utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let data = data
			{
				comp(data)
			}
			else
			{
				print(error ?? "Error")
			}
		}
		task.resume()
	}
}
