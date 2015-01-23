(function() {
  var app;

  app = angular.module('noTube', ['ui.bootstrap']);

  app.config([
    '$httpProvider', function($httpProvider) {
      $httpProvider.defaults.useXDomain = true;
      return delete $httpProvider.defaults.headers.common['X-Requested-With'];
    }
  ]);

}).call(this);
