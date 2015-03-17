angular.module('ble').factory 'GimbalService', ['supersonic', (supersonic) ->
	gimbalService = {

	}

	gimbalService.start = ->
		gimbalmgr.setBeaconEventCallback((result)->
			console.log "beacon event callback success! " + result
			return
		(error)->
			console.log "beacon event callback error! " + error
			return
		)

		gimbalmgr.setPlaceEventCallback((result)->
			console.log "place event callback success! " + result
			return
		(error)->
			console.log "place event callback error! " + error
			return
		)

		gimbalmgr.startService((result)->
			console.log "start success! " + result
			return
		(error)->
			console.log "start error! " + error
			return
		"4510f278774e70a3999df963c25b6fdf986564d2cdf08b35ec09a87244d28437"
		)
		return

	gimbalService
]
