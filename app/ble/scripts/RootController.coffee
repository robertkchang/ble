angular
	.module('ble')
	.controller 'RootController', ['$scope', 'supersonic', ($scope, supersonic) ->

		$scope.scan = ->
			view = new supersonic.ui.View("ble#list")
			supersonic.ui.layers.push(view)

]
