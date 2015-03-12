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
						btMgr.connectDevice(device)

					found = true
					break
				x++

			if !found
				scope.$apply ->
					scope.beacons.push(device)
					if device.rssi < 0 && device.rssi != 127 && device.name.indexOf("Robert") >= 0
						btMgr.connectDevice(device)

		$scope.scan = ->
			alert "start scan!"
			btMgr.startScan()




]
