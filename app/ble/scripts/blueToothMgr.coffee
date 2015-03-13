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

	# setMode:: User - look for iOS devices, beacon - look for beacon peripherals
	blueToothMgr.setMode = (mode) ->
		if mode == 'user'
			blueToothMgr.mode = 'user'
		else if mode == 'beacon'
			blueToothMgr.mode = 'beacon'

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

	# addDevice -
	blueToothMgr.addDevice = (device)->
		found = false
		x = 0
		while x < blueToothMgr.beacons.length
			if blueToothMgr.beacons[x] && device.address == blueToothMgr.beacons[x].address
				blueToothMgr.beacons[x] = {}
				blueToothMgr.beacons[x] = device

				if device.rssi < 0 && device.rssi != 127 && device.name.indexOf("Robert") >= 0
					btMgr.connectDevice(device)

				found = true
				break
			x++

		# TODO: How do we handle the 'user' mode?
		if !found
			if mode != 'user'
				blueToothMgr.beacons.push(device)

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
				console.log 'Stop scan error ' + JSON.stringify(error)
				return
		)

	# startScan:: Initalize Bluetooth Scanner on an interval
	# param {user: 'string'}
	# If param is true, we will only look for users otherwise beacons
	# TODO: Hook up and verify resolve/reject
	blueToothMgr.startScan = (calback)->
		promise = new Promise (resolve, reject) ->
			clearScan = ->
				window.clearInterval blueToothMgr.scanInterval

				blueToothMgr.stopScan (result) ->
					if result && result.error
						reject result.error
					else
						resolve {
							beacons: blueToothMgr.beacons
							user: blueToothMgr.user
						}

			scanStart = ->
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
							blueToothMgr.addDevice(result)

					(error)->
						console.log  JSON.stringify(error)
						blueToothMgr.scanning = false
					{"serviceUuids" : filters }
				)

			if !blueToothMgr.scanInit
				# Let the initialize function call the scanner code when it's done
				blueToothMgr.init(true)
			else if !blueToothMgr.scanning
				scanStart()

		callback promise

	return blueToothMgr
]
