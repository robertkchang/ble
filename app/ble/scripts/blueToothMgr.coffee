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
				blueToothMgr.fetchServices(device)
				return
			(error) ->
				console.log("it broked!" + JSON.stringify(error))
				return
			({address: device.address})
		)

	# fetchServices:: Fetch services from a connected device
	blueToothMgr.fetchServices = (device) ->
		console.log 'in fetchServices: ' + device.address
		bluetoothle.services(
			(services) ->
				console.log("test test" + JSON.stringify(services))
				return
			(error) ->
				console.log("it broked!" + JSON.stringify(error))
				return
			{address: device.address, serviceUuids: []}
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
	blueToothMgr.startScan = ()->
		promise = new Promise(resolve, reject) ->
			console.log 'in startScan'
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
						if result && result.address && result.rssi
							blueToothMgr.addDevice(result)

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
		return promise

	return blueToothMgr
]
