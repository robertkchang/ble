angular
	.module('ble')
	# .controller 'RootController', ['$scope', 'supersonic', 'BlueToothMgr', ($scope, supersonic, btMgr) ->
	.controller 'RootController', ['$scope', 'supersonic', 'GimbalMgr', ($scope, supersonic, gimbalMgr) ->
		$scope.scanInit = false
		$scope.scanning = false
		$scope.isConnecting = false
		$scope.beacons = []

		$scope.stop = ->
			# btMgr.stopScan()
			gimbalMgr.stopScan()
			return

		$scope.scan = ->
			# btMgr.startScan((result)->
			# 	console.log 'scan result: ' + result
			# 	return
			# )

			gimbalMgr.startService((result)->
				console.log 'scan result: ' + result
				return
			)

		return
]
