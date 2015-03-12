angular
	.module('ble')
	.controller 'RootController', ['$scope', 'supersonic', ($scope, supersonic) ->
		$scope.scanInit = false
		$scope.scanning = false
		$scope.beacons = []


		$scope.scan = ->
			initalize = ->
				bluetoothle.initialize(
					(result)->
						console.log JSON.stringify(result)
						$scope.scanInit = true
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
						alert 'scan success ' +  JSON.stringify(result)
						console.log  JSON.stringify(result)
						$scope.beacons = result
						$scope.scanning = false
						return
					(error)->
						alert 'scan error ' +  JSON.stringify(error)
						console.log  JSON.stringify(error)
						$scope.scanning = false
						return
					{"serviceUuids" : []}
				)


			stopScanning = ->
				console.log "calling stopScan"

				bluetoothle.stopScan(
					(result)->
						alert 'stop scan success ' + result
						return
					(error)->
						alert 'stop scan error ' + error
						return
				)
				return


			if !$scope.scanInit
				initalize()

			if !$scope.scanning
				startScanning()




]
