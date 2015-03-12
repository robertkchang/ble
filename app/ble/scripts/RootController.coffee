angular
	.module('ble')
	.controller 'RootController', ['$scope', 'supersonic', ($scope, supersonic) ->
		$scope.scanInit = false
		$scope.scanning = false
		$scope.isConnecting = false
		$scope.beacons = []

		$scope.stop = ->
			bluetoothle.stopScan(
				(result)->
					alert 'stop scan success ' + result
					$scope.$apply ->
						$scope.beacons = []

					$scope.scanning = false
					return
				(error)->
					alert 'stop scan error ' + error
					return
			)

		$scope.fetchServices = (address) ->
			bluetoothle.services(
				(services) ->
					console.log("test test" + JSON.stringify(services))
					$scope.isConnecting = false
					return
				(error) ->
					console.log("it broked!" + JSON.stringify(error))
					$scope.isConnecting = false
					return
				{address: address, serviceUuids: []}
			)

		$scope.connectDevice = (device) ->
			if !$scope.isConnecting
				$scope.isConnecting = true
				bluetoothle.connect(
					(result) ->
						if result.status == "connected"
							scope = angular.element(document.getElementById 'root').scope()
							scope.fetchServices(result.address)
							return
					(error) ->
						console.log("it broked!" + JSON.stringify(error))
						$scope.isConnecting = false
						return
					({address: device.address})
				)


		$scope.addDevice = (device)->
			if !$scope
				scope = angular.element(document.getElementById 'root').scope()
			else
				scope = $scope

			found = false
			x = 0
			while x < scope.beacons.length
				if scope.beacons[x] && device.address == scope.beacons[x].address
					scope.$apply ->
						scope.beacons[x] = {}
						scope.beacons[x] = device

					if device.rssi < 0 && device.rssi != 127 && device.name.indexOf("Robert") >= 0
						scope.connectDevice(device)

					found = true
					break
				x++

			if !found
				scope.$apply ->
					scope.beacons.push(device)
					if device.rssi < 0 && device.rssi != 127 && device.name.indexOf("Robert") >= 0
						scope.connectDevice(device)

		$scope.scan = ->
			initalize = ->
				bluetoothle.initialize(
					(result)->
						console.log JSON.stringify(result)
						$scope.scanInit = true

						startScanning()
						return
					(error)->
						$scope.scanInit = false
						console.log JSON.stringify(error)
						alert 'blue tooth failed to init!' + JSON.stringify(error)
						return
					{request: true}
				)
				console.log "done init"

			startScanning = ->
				console.log "calling startScanning"
				$scope.scanning = true

				bluetoothle.startScan(
					(result)->
						console.log  JSON.stringify(result)
						if result && result.status && result.address && result.rssi
							scope = angular.element(document.getElementById 'root').scope()
							scope.addDevice(result)

						$scope.scanning = false
						return
					(error)->
						console.log  JSON.stringify(error)
						$scope.scanning = false
						return
					{"serviceUuids" : []}
				)

			if !$scope.scanInit
				initalize()
			else if !$scope.scanning
				startScanning()





]
