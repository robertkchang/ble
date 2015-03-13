angular.module('ble').factory 'BlueToothMgr', ['supersonic', (supersonic) ->
	blueToothMgr = {
		mode: 'user'	# Service Mode: Search for User or Beacon
		scanInit: false
		scanning: false

		services: {
			user: ['323a-asd234-adf']
			beacon: ['someHash']
		}

		beacons: []
	}

	# init:: Initalize the Bluetooth service - let user activate bluetooth functionality
	blueToothMgr.init = (scan)->
		bluetoothle.initialize(
			(result)->
				console.log JSON.stringify(result)
				blueToothMgr.scanInit = true

				if scan && scan == true
					blueToothMgr.startScan()
				return
			(error)->
				blueToothMgr.scanInit = false
				console.log JSON.stringify('BlueToothMgr::init-> Failed to initialize'  + error)
				alert 'blue tooth failed to init!' + JSON.stringify(error)
				return
			{request: true}
		)

	# connectDevice:: Connect to a device
	blueToothMgr.connectDevice = (device) ->
		bluetoothle.connect(
			(result) ->
				blueToothMgr.fetchServices(address)
				return
			(error) ->
				console.log("it broked!" + JSON.stringify(error))
				return
			({address: device.address})
		)

	# fetchServices:: Fetch services from a connected device
	blueToothMgr.fetchServices = (device) ->
		bluetoothle.services(
			(services) ->
				console.log("test test" + JSON.stringify(services))
				return
			(error) ->
				console.log("it broked!" + JSON.stringify(error))
				return
			{address: address, serviceUuids: []}
		)

	blueToothMgr.addDevice = (device)->
		found = false
		x = 0
		while x < scope.beacons.length
			if scope.beacons[x] && device.address == scope.beacons[x].address
				scope.$apply ->
					scope.beacons[x] = {}
					scope.beacons[x] = device

				if device.rssi < 0 && device.rssi != 127 && device.name.indexOf("Robert") >= 0
					btMgr.connectDevice(device)

				found = true
				break
			x++

		if !found
			scope.beacons.push(device)
			if device.rssi < 0 && device.rssi != 127 &&
				btMgr.connectDevice(device)

	# stopScan:: Hault BlueTooth Scanning
	blueToothMgr.stopScan = ->
		bluetoothle.stopScan(
			(result)->
				# alert 'Stop scan success ' + result
				blueToothMgr.$apply ->
					blueToothMgr.beacons = []

				blueToothMgr.scanning = false
				return
			(error)->
				# alert 'Stop scan error ' + error
				return
		)

	# startScan:: Initalize Bluetooth Scanner on an interval
	# param {user: 'string'}
	# If param is true, we will only look for users otherwise beacons
	blueToothMgr.startScan = (calback)->
		scanStart = ->
			filters = []
			blueToothMgr.scanning = true

			# TODO: We need proper service hash's hooked up here
			# if mode == 'user'
			# 	filters = blueToothMgr.services.user
			# else
			# 	filters = blueToothMgr.services.beacon

			bluetoothle.startScan(
				(result)->
					console.log  JSON.stringify(result)
					if mode == 'user' && result && result.address && result.rssi
						blueToothMgr.addDevice(result)
					else if result && result.status && result.address && result.rssi
							blueToothMgr.addDevice(result)

					return
				(error)->
					console.log  JSON.stringify(error)
					blueToothMgr.scanning = false
					return
				{"serviceUuids" : filters }
			)

		if !blueToothMgr.scanInit
			# Let the initialize function call the scanner code when it's done
			blueToothMgr.init(true)
		else if !blueToothMgr.scanning
			scanStart()

	return blueToothMgr
]
