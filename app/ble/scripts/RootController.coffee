angular
	.module('ble')
	.controller 'RootController', ['$scope', 'supersonic', 'BlueToothMgr', ($scope, supersonic, btMgr) ->
		$scope.scanInit = false
		$scope.scanning = false
		$scope.isConnecting = false
		$scope.beacons = []

		$scope.stop = ->
			btMgr.stopScan()
			return

		$scope.scan = ->
			btMgr.startScan( (results)->

			)

]
