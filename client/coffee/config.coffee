app = angular.module 'noTube',['ui.bootstrap','facebook']

app.config ['$httpProvider',($httpProvider)->
	$httpProvider.defaults.useXDomain = true
	delete $httpProvider.defaults.headers.common['X-Requested-With']
]

app.config ['FacebookProvider',(FacebookProvider)->
	FacebookProvider.init '363561610496476'
]

app.directive ['debug', ->
	restrict:	'E',
	scope: {
		expression: '=val'
	},
	template:	'<pre>{{debug(expression)}}</pre>',
	link: (scope) ->
		scope.debug = (exp) ->
			angular.toJson(exp, true)
]