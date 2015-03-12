angular
	.module('ble')
	.controller 'ListController', ['$scope', 'supersonic', ($scope, supersonic) ->

		$scope.beacons = []

		$scope.init = ->
			console.log "before init"
			bluetoothle.initialize(
				(result)->
					console.log JSON.stringify(result)
					return
				(error)->
					console.log JSON.stringify(error)
					return
				{request: true}
			)
			console.log "done init"

			console.log "calling startScan"
			bluetoothle.startScan(
				(result)->
					alert 'scan success ' + result
					$scope.beacons = result
					return
				(error)->
					alert 'scan error ' + error
					return
				{"serviceUuids" : []}
			)

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

		# $scope.init = ->
		# 	bluetoothSerial.list ((devices) ->
		# 		alert devices
		# 		devices.forEach (device) ->
		# 			alert device.id
		# 			return
		# 		return
		# 	), ->
		# 		alert 'failed'
		# 		return
		# 	return

		$scope.init()
]
