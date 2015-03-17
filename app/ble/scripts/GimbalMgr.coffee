angular.module('ble').factory 'GimbalService', ['supersonic', (supersonic) ->
	gimbalService = {

	}

	gimbalService.start = ->
		gimbalmgr.startService((result)->
			console.log "success! " + result
			return
		(error)->
			console.log "error! " + error
			return
		"4510f278774e70a3999df963c25b6fdf986564d2cdf08b35ec09a87244d28437"
		)
		return

	gimbalService
]
