angular
	.module('ble')
	.controller 'ListController', ['$scope', 'supersonic', ($scope, supersonic) ->

		$scope.beacons = []

		$scope.init = ->
			console.log "before init"




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
