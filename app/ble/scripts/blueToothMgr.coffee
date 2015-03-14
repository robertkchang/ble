angular.module('ble').factory 'BlueToothMgr', ['supersonic', (supersonic) ->
	blueToothMgr = {
		mode: 'user'	# Service Mode: Search for User or Beacon
		scanInit: false
		scanning: false
		scanInterval: null

		services: {
			user: ['323a-asd234-adf']
			beacon: ['someHash']
		}

		beacons: []
		user: null
	}

	# init:: Initalize the Bluetooth service - let user activate bluetooth functionality
	blueToothMgr.init = (scan) ->
		console.log 'in init'
		promise = new Promise (resolve, reject) ->
			bluetoothle.initialize(
				(result)->
					console.log JSON.stringify(result)
					blueToothMgr.scanInit = true
					resolve result
					# if scan && scan == true
					# 	blueToothMgr.startScan()
					return
				(error)->
					blueToothMgr.scanInit = false
					console.log JSON.stringify('BlueToothMgr::init-> Failed to initialize'  + error)
					alert 'blue tooth failed to init!' + JSON.stringify(error)
					reject error
					return
				{request: true}
			)

		promise

	# setMode:: User - look for iOS devices, beacon - look for beacon peripherals
	blueToothMgr.setMode = (mode) ->
		if mode == 'user'
			blueToothMgr.mode = 'user'
		else if mode == 'beacon'
			blueToothMgr.mode = 'beacon'

	# connectDevice:: Connect to a device
	blueToothMgr.connectDevice = (device) ->
		console.log 'in connectDevice'
		bluetoothle.connect(
			(result) ->
				console.log 'connected: ' + JSON.stringify(result)
				if result.status == 'connected'
					blueToothMgr.fetchServices(device)
					return
				return
			(error) ->
				console.log("connect broked!" + JSON.stringify(error))
				if error.message.indexOf("Device previously connected")>=0
					blueToothMgr.disconnectDevice(device, true)
					return
				return
			({address: device.address})
		)

	blueToothMgr.reconnectDevice = (device) ->
		console.log 'in reconnectDevice'
		bluetoothle.reconnect(
			(result) ->
				console.log 'reconnected: ' + JSON.stringify(result)
				if result.status == 'connected'
					blueToothMgr.fetchServices(device)
					return
				return
			(error) ->
				console.log("reconnect broked!" + JSON.stringify(error))
				return
			({address: device.address})
		)

	blueToothMgr.disconnectDevice = (device, doReconnect) ->
		console.log 'in disconnectDevice'
		bluetoothle.disconnect(
			(result) ->
				console.log 'disconnected: ' + JSON.stringify(result)
				if result.status == 'disconnected' && doReconnect
					blueToothMgr.reconnectDevice(device)
				return
			(error) ->
				console.log("disconnect broked!" + JSON.stringify(error))
				if error.message == 'Device is disconnected' && doReconnect
					blueToothMgr.reconnectDevice(device)
				return
			({address: device.address})
		)

	# fetchServices:: Fetch services from a connected device
	blueToothMgr.fetchServices = (device) ->
		console.log 'in fetchServices: ' + device.address
		bluetoothle.services(
			(result) ->
				console.log("fetched" + JSON.stringify(result))
				if result.status == 'services'
					blueToothMgr.fetchCharacteristics(device, result.serviceUuids)
				return
			(error) ->
				console.log("fetched broked!" + JSON.stringify(error))
				return
			{address: device.address, serviceUuids: []}
		)

	# blueToothMgr.fetchCharacteristics = (device, serviceUUIDs) ->
	# 	console.log 'in fetchCharacteristics: ' + device.address + "; serviceUUIDs: " + serviceUUIDs
	#
	# 	Promise.race(serviceUUIDs).then (serviceUUID)->
	# 		blueToothMgr.fetchCharacteriticsForOneService device, serviceUUID
	# 		return

	blueToothMgr.fetchCharacteristics = (device, serviceUUIDs) ->
		console.log 'in fetchCharacteristics: ' + device.address
		blueToothMgr.fetchCharacteriticsForOneService device, 'E20A39F4-73F5-4BC4-A12F-17D1AD07A961'
		return

	blueToothMgr.fetchCharacteriticsForOneService = (device, serviceUUID) ->
		console.log 'in fetchCharacteriticsForOneService for ' + serviceUUID
		promise = new Promise (resolve, reject) ->
			bluetoothle.characteristics(
				(result) ->
					console.log("fetched chars for service " + serviceUUID + ": " + JSON.stringify(result))
					blueToothMgr.subscribeCharacteristic device, result.serviceUuid, result.characteristics[0].characteristicUuid
					resolve result
					return
				(error) ->
					console.log("fetched chars broke for service " + serviceUUID + ": " + JSON.stringify(error))
					reject error
					return
				{address: device.address, serviceUuid: serviceUUID, characteristicUuids: []}
			)
		promise

	blueToothMgr.subscribeCharacteristic = (device, serviceUUID, characteristicUuid) ->
		console.log 'in subscribeCharacteristic for serviceUUID: ' + serviceUUID + " and characteristicUuID: " + characteristicUuid
		charValue = ""
		bluetoothle.subscribe(
			(result) ->
				console.log("subscribe for characteristic " + characteristicUuid + ": " + JSON.stringify(result))
				if result.status == 'subscribedResult'
					resultInBytes = bluetoothle.encodedStringToBytes(result.value)
					charValue += bluetoothle.bytesToString(resultInBytes)
					console.log "charValue: " + charValue
					return
				return
			(error) ->
				console.log("subscribe broke for characteristic " + characteristicUuid + ": " + JSON.stringify(error))
				return
			{address: device.address, serviceUuid: serviceUUID, characteristicUuid: characteristicUuid}
		)

	# addDevice -
	blueToothMgr.addDevice = (device)->
		console.log 'in addDevice'
		found = false
		x = 0
		while x <= blueToothMgr.beacons.length
			if blueToothMgr.beacons[x] && device.address == blueToothMgr.beacons[x].address
				blueToothMgr.beacons[x] = {}
				blueToothMgr.beacons[x] = device
				found = true
				break
			x++

		# TODO: How do we handle the 'user' mode? and how do we handle the 'beacon' mode?
		if !found
			if blueToothMgr.mode != 'user'
				blueToothMgr.beacons.push(device)
			else
				doSTuff = 'haha' # Set up the 'user' case

		# TODO: We need to figure out RSSI strength and stuff...
		if device.rssi < 0 && device.rssi != 127
			console.log 'about to connect'
			blueToothMgr.connectDevice(device)
			return

	# stopScan:: Hault BlueTooth Scanning
	blueToothMgr.stopScan = ->
		console.log 'Ceasing scanning'
		bluetoothle.stopScan(
			(result)->
				# alert 'Stop scan success ' + result
				blueToothMgr.beacons = []
				blueToothMgr.scanning = false
				return
			(error)->
				console.log 'Stop scan error ' + JSON.stringify(error)
				return
		)

	# startScan:: Initalize Bluetooth Scanner on an interval
	# param {user: 'string'}
	# If param is true, we will only look for users otherwise beacons
	blueToothMgr.startScan = (callback)->
		console.log 'in startScan'
		clearScan = ->
			console.log 'in startScan clearScan'
			blueToothMgr.stopScan()
			window.clearInterval blueToothMgr.scanInterval
			return

			# if !blueToothMgr.scanning

		scanStart = ->
			console.log 'in startScan scanStart'
			filters = []
			blueToothMgr.scanning = true

			# TODO: We need proper service hash's hooked up here
			# if mode == 'user'
			# 	filters = blueToothMgr.services.user
			# else
			# 	filters = blueToothMgr.services.beacon

			blueToothMgr.scanInterval = window.setInterval clearScan, 5000
			bluetoothle.startScan(
				(result)->
					console.log  JSON.stringify(result)
					if blueToothMgr.mode == 'user' && result && result.address && result.rssi && (result.name!=null &&result.name.indexOf('Robert') >= 0)
						blueToothMgr.addDevice(result, (result)->
							callback result
							)
					else if result && result.status && result.address && result.rssi  && (result.name!=null &&result.name.indexOf('Robert') >= 0)
						blueToothMgr.addDevice(result, (result) ->
							if !result || result.error
								callback result
								return
							else
								callback result
								return
							)

					return
				(error)->
					console.log  JSON.stringify(error)
					blueToothMgr.scanning = false
					callback JSON.stringify(error)
					return
				{"serviceUuids" : filters }
			)
			return

		if !blueToothMgr.scanInit
			# Let the initialize function call the scanner code when it's done
			blueToothMgr.init(true).then ->
				console.log 'scanning: ' + blueToothMgr.scanning
				if !blueToothMgr.scanning
					scanStart()
					return
			return
		else
			console.log 'scanning: ' + blueToothMgr.scanning
			if !blueToothMgr.scanning
				scanStart()
				return
			return

	return blueToothMgr
]
