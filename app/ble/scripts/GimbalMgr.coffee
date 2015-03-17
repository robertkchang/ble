angular.module('ble').factory 'GimbalMgr', ['supersonic', (supersonic) ->
	gimbalMgr = {

	}

	gimbalMgr.startService = (cb) ->
		Gimbal.startService "1b47158de145b47f5330fc8dae7706fe0ef8c9b89b5ced8b1415c1f823e3591b", cb
		return

	gimbalMgr
]
