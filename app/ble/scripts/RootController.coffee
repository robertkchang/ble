angular
	.module('ble')
	# .controller 'RootController', ['$scope', 'supersonic', 'BlueToothMgr', ($scope, supersonic, btMgr) ->
	.controller 'RootController', ['$scope', 'supersonic', 'GimbalService', ($scope, supersonic, gimbalService) ->
		$scope.scanInit = false
		$scope.scanning = false
		$scope.isConnecting = false
		$scope.beacons = []

		$scope.stop = ->
			# btMgr.stopScan()
			# gimbalService.stopScan()
			return

		$scope.scan = ->
			# btMgr.startScan((result)->
			# 	console.log 'scan result: ' + result
			# 	return
			# )

			gimbalService.start()

		return
]
