app = angular.module 'noTube',['ui.bootstrap']
app.config ['$httpProvider',($httpProvider)->
	$httpProvider.defaults.useXDomain = true
	delete $httpProvider.defaults.headers.common['X-Requested-With']
]