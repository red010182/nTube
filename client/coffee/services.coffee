# class FacebookManager
# 	constructor: (@$scope,@Facebook) ->
# 		@$scope.$watch ()=>
# 			@Facebook.isReady()
# 		, (newVal)=>
# 			@$scope.facebookReady = true if newVal	
# 		@isLoggedIn = false
# 		@$scope.$on 'Facebook:statusChange',@onStatusChanged
# 	login: ->
# 		@Facebook.login (res)=>
# 			if res.status is 'connected'
# 				@$scope.logged = true
# 				@me()
# 			console.log res
	
# 	getLoginStatus: ->
# 		@Facebook.getLoginStatus (res)=>
# 			console.log res.status
# 			if res.status is 'connected'
# 				@isLoggedIn = true
	
# 	intentLogin: ->
# 		@login() unless @isLoggedIn
		
# 	me: ->
# 		@Facebook.api '/me',(res)=>
# 			@$scope.$apply ()=>
# 				user = res
# 				console.log user
	
# 	onStatusChanged:(ev,data)=>
# 		console.log "Status: "
# 		console.log data
# 		status = data.status
# 		if status is 'connected'
# 			@isLoggedIn
# 			@$scope.logged = true
# 			@me()
# 			# ...
	
# 	logout: ->
# 		@Facebook.logout (res)=>
# 			console.log res
# 			@$scope.$apply ()=>
# 				$scope.user = {}
# 				$scope.logged = false
# 				@isLoggedIn = false

# m = angular.module 'noTube'
# m.service 'FacebookManager',['$scope','Facebook',FacebookManager]
