//
//  BLEManager.swift
//  RoundBLE
//
//  Created by Yusk1450 on 2018/02/20.
//  Copyright © 2018年 Yusk. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BLEManagerDelegate: class
{
	func bleManagerFoundPeripheral(bleManager:BLEManager, peripheral:CBPeripheral)
	func bleManagerDidConnectPeripheral(bleManager:BLEManager)
	func bleManagerDidDisconnectPeripheral(bleManager:BLEManager)
	func bleManagerDidFailToConnectPeripheral(bleManager:BLEManager)
}

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
	var centralManager:CBCentralManager?
	var foundPeripherals = [CBPeripheral]()
	var pickupPeripheralNames = [String]()
	var isConnected = false
	var connectedPeripheral:CBPeripheral?
	var connectedCharacteristic:CBCharacteristic?
	weak var delegate:BLEManagerDelegate?
	
	static let shared = BLEManager()
	
	override init()
	{
		super.init()
		
		self.centralManager = CBCentralManager(delegate: self, queue: nil)
	}
	
	func disconnectPeripheral()
	{
		if let peripheral = self.connectedPeripheral
		{
			self.centralManager?.cancelPeripheralConnection(peripheral)
		}
	}
	
	func refreshFoundPeripherals()
	{
		self.foundPeripherals.removeAll()
	}
	
	func writeValue(data:Data)
	{
		if (!isConnected)
		{
			return
		}
		
		if let characteristic = self.connectedCharacteristic
		{
			print("送信しました")
			self.connectedPeripheral?.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
		}
	}
	
	func connect(peripheral:CBPeripheral)
	{
		self.centralManager?.connect(peripheral, options: nil)
	}
	
	// MARK: - CBCentralManager Delegate Methods
	
	func centralManagerDidUpdateState(_ central: CBCentralManager)
	{
		switch central.state
		{
			// BluetoothがONになっているとき...
			case .poweredOn:
				self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
			default:
				break
		}
	}
	
	/* -------------------------------------------------------
	 * ペリフェラルが見つかったときに呼び出される
	------------------------------------------------------- */
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
	{
//		print(peripheral.name)
		
		var exists = false
		for peri in self.foundPeripherals
		{
			if (peri.identifier.uuidString == peripheral.identifier.uuidString)
			{
				exists = true
			}
		}
		
		if (!exists)
		{
			if (self.pickupPeripheralNames.count <= 0)
			{
				self.foundPeripherals.append(peripheral)
				self.delegate?.bleManagerFoundPeripheral(bleManager: self, peripheral: peripheral)
			}
			else
			{
				// 指定した名前のペリフェラルのみ
				for name in self.pickupPeripheralNames
				{
					if let srcName = peripheral.name
					{
						if (srcName.contains(name))
						{
							self.foundPeripherals.append(peripheral)
							self.delegate?.bleManagerFoundPeripheral(bleManager: self, peripheral: peripheral)
						}
					}
				}
			}
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
	{
		print("「"+peripheral.name!+"」に接続しました")
		self.isConnected = true
		self.connectedPeripheral = peripheral
		self.connectedPeripheral?.delegate = self
		self.delegate?.bleManagerDidConnectPeripheral(bleManager: self)
		
		// サービスを検索する
		peripheral.discoverServices(nil)
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
	{
		print("接続できませんでした")
		self.delegate?.bleManagerDidFailToConnectPeripheral(bleManager: self)
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
	{
		print("切断されました")
		self.isConnected = false
		self.connectedPeripheral = nil
		self.connectedCharacteristic = nil
		self.delegate?.bleManagerDidDisconnectPeripheral(bleManager: self)
	}
	
	// MARK: - CBPeripheral Delegate Methods

	/* -------------------------------------------------------
	* サービスが見つかったときに呼び出される
	------------------------------------------------------- */
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
	{
		print("サービスが見つかりました")
//		print(peripheral.services)
		
		if let services = peripheral.services
		{
			for service in services
			{
				// UART
				// https://learn.adafruit.com/introducing-adafruit-ble-bluetooth-low-energy-friend/uart-service
				if (service.uuid.uuidString == "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
				{
					// キャラクタリスティックを検索する
					peripheral.discoverCharacteristics(nil, for: service)
					print(service)
				}
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
	{
		print("キャラクタリスティックが見つかりました")
//		print(service.characteristics)
		
		if let characteristics = service.characteristics
		{
			for characteristic in characteristics
			{
				// TX
				if (characteristic.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
				{
					self.connectedCharacteristic = characteristic
					print(characteristic)
				}
			}
		}
	}
	
	/* -------------------------------------------------------
	* ペリフェラルへの書き込みが成功したときに呼び出される
	------------------------------------------------------- */
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?)
	{
		print("書き込みに成功しました")
	}
}
