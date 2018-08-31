//
//  iBot.swift
//  iBotLib2
//
//  Created by Yusk1450 on 2018/08/29.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit
import CoreBluetooth

public enum iBotStatus
{
	case OK
	case NotInitialize			// 初期化されていない
	case DisconnectNetwork		// ネットワークに繋がっていない
	case DisconnectHardware		// ハードウェアに繋がっていない
}

class iBotCore:NSObject, BLEManagerDelegate
{
	static let shared = iBotCore()
	
	private var iBotHardwareUUID:String?
	
	private override init()
	{
		UIApplication.shared.isIdleTimerDisabled = true
		UIApplication.shared.isStatusBarHidden = true
	}
	
	public func setup(uuid:String)
	{
		self.iBotHardwareUUID = uuid
		
		let ble = BLEManager.shared
		ble.pickupPeripheralNames = ["Adafruit Bluefruit LE"]
		ble.delegate = self
	}
	
	public func getBundle() -> Bundle?
	{
		guard let bundlePath = Bundle.main.path(forResource: "iBotLib2", ofType: "framework", inDirectory: "Frameworks") else
		{
			return nil
		}
		
		return Bundle(path: bundlePath)
	}
	
	public func getStatus() -> iBotStatus
	{
		if (self.iBotHardwareUUID == nil)
		{
			return iBotStatus.NotInitialize
		}
		
		let ble = BLEManager.shared
		if (!ble.isConnected)
		{
			return iBotStatus.DisconnectHardware
		}
		
		// TODO: ネットワークチェック
//		return iBotStatus.DisconnectNetwork

		return iBotStatus.OK
	}
}

extension iBotCore
{
	func bleManagerFoundPeripheral(bleManager: BLEManager, peripheral: CBPeripheral)
	{
		if (bleManager.isConnected)
		{
			return
		}
		
		guard let uuid = self.iBotHardwareUUID else
		{
			return
		}
		
		if (peripheral.identifier.uuidString == uuid)
		{
			print("ペリフェラル発見")
			print(peripheral.identifier.uuidString)
			
			bleManager.connect(peripheral: peripheral)
		}
	}
	
	func bleManagerDidConnectPeripheral(bleManager: BLEManager)
	{
		print("ペリフェラル接続")
	}
	
	func bleManagerDidDisconnectPeripheral(bleManager: BLEManager)
	{
		print("ペリフェラル切断")
	}
	
	func bleManagerDidFailToConnectPeripheral(bleManager: BLEManager)
	{
		print("ペリフェラルに接続できませんでした")
	}
}
