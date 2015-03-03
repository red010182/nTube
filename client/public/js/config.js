(function() {
  var app;

  app = angular.module('noTube', ['ui.bootstrap', 'facebook']);

  app.config([
    '$httpProvider', function($httpProvider) {
      $httpProvider.defaults.useXDomain = true;
      return delete $httpProvider.defaults.headers.common['X-Requested-With'];
    }
  ]);

  app.config([
    'FacebookProvider', function(FacebookProvider) {
      return FacebookProvider.init('363561610496476');
    }
  ]);

  app.directive([
    'debug', function() {
      return {
        restrict: 'E',
        scope: {
          expression: '=val'
        },
        template: '<pre>{{debug(expression)}}</pre>',
        link: function(scope) {
          return scope.debug = function(exp) {
            return angular.toJson(exp, true);
          };
        }
      };
    }
  ]);

}).call(this);
