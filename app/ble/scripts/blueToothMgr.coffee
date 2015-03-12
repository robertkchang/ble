angular.module('ble').factory 'BlueToothMgr', ['supersonic', (supersonic) ->
	blueToothMgr = {
		scanInit: false
		scanning: false
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
	blueToothMgr.startScan = ()->
		blueToothMgr.scanning = true

		scanStart = ->
			bluetoothle.startScan(
				(result)->
					console.log  JSON.stringify(result)
					if result && result.status && result.address && result.rssi
						blueToothMgr.addDevice(result)

					blueToothMgr.scanning = false
					return
				(error)->
					console.log  JSON.stringify(error)
					blueToothMgr.scanning = false
					return
				{"serviceUuids" : [] }
			)

		if !blueToothMgr.scanInit
			# Let the initialize function call the scanner code when it's done
			blueToothMgr.init(true)
		else if !blueToothMgr.scanning
			scanStart()

	return blueToothMgr
]
