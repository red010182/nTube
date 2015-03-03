(function() {
  var FacebookManager, ParserController, Playlist, Video, app,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  FacebookManager = (function() {
    function FacebookManager($scope, $http, Facebook) {
      this.$scope = $scope;
      this.$http = $http;
      this.Facebook = Facebook;
      this.onStatusChanged = __bind(this.onStatusChanged, this);
      this.$scope.$watch((function(_this) {
        return function() {
          return _this.Facebook.isReady();
        };
      })(this), (function(_this) {
        return function(newVal) {
          if (newVal) {
            return _this.$scope.facebookReady = true;
          }
        };
      })(this));
      this.userIsConnected = false;
      this.$scope.$on('Facebook:statusChange', this.onStatusChanged);
    }

    FacebookManager.prototype.login = function() {
      if (this.userIsConnected) {
        return;
      }
      return this.Facebook.login((function(_this) {
        return function(res) {
          if (res.status === 'connected') {
            _this.userIsConnected = false;
            _this.$scope.logged = true;
            return _this.me();
          }
        };
      })(this), {
        scope: 'public_profile, email'
      });
    };

    FacebookManager.prototype.onStatusChanged = function(ev, data) {
      var status;
      console.log("FB Status: " + data.status);
      status = data.status;
      if (status === 'connected') {
        this.userIsConnected = true;
        this.$scope.logged = true;
        return this.me();
      }
    };

    FacebookManager.prototype.me = function() {
      return this.Facebook.api('/me', (function(_this) {
        return function(res) {
          var dict;
          dict = {};
          dict.screenName = res.name;
          dict.facebookID = res.id;
          dict.gender = res.gender;
          dict.email = res.email;
          return _this.loginToServer(dict);
        };
      })(this));
    };

    FacebookManager.prototype.loginToServer = function(userDict, callback) {
      var request;
      request = this.$http.post('/loginByFacebook', userDict);
      return request.then((function(_this) {
        return function(res) {
          if (res.status === 200) {
            return _this.initUser(res.data);
          }
        };
      })(this));
    };

    FacebookManager.prototype.initUser = function(user) {
      if (user) {
        return this.$scope.user = user;
      }
    };

    FacebookManager.prototype.logout = function() {
      return this.Facebook.logout((function(_this) {
        return function(res) {
          return _this.$scope.$apply(function() {
            _this.$scope.user = {};
            _this.$scope.logged = false;
            return _this.userIsConnected = false;
          });
        };
      })(this));
    };

    return FacebookManager;

  })();

  Video = (function() {
    function Video(obj) {
      var link;
      this.videoID = obj["media$group"]["yt$videoid"]["$t"];
      this.link = "http://www.youtube.com/v/" + this.videoID;
      this.duration = +obj["media$group"]["media$content"][0]["duration"];
      this.title = obj["title"]["$t"];
      this.image = obj["media$group"]["media$thumbnail"][1];
      link = "https://www.youtube.com/watch?v=" + this.videoID;
      this.mp3Url = "/download?url=" + (encodeURIComponent(link));
    }

    return Video;

  })();

  Playlist = (function() {
    function Playlist(obj) {
      var e;
      this.title = obj.feed.title;
      this.subtitle = obj.feed.subtitle;
      this.author = obj.feed.author;
      this.playlistID = obj.feed.playlistID;
      this.entry = obj.feed.entry;
      this.videos = (function() {
        var _i, _len, _ref, _results;
        _ref = this.entry;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          _results.push(new Video(e));
        }
        return _results;
      }).call(this);
    }

    return Playlist;

  })();

  ParserController = (function() {
    function ParserController($scope, $http, $log, $sce, FacebookManager) {
      this.$scope = $scope;
      this.$http = $http;
      this.$log = $log;
      this.$sce = $sce;
      this.FacebookManager = FacebookManager;
      this.currentPlayingIndex = -1;
      this.player = videojs('really-cool-video');
      this.player.on('ended', (function(_this) {
        return function() {
          console.log('video end');
          return _this.playNextVideo();
        };
      })(this));
    }

    ParserController.prototype.getPlaylist = function(url) {
      var playlistID, request, videoID;
      if (!url) {
        url = this.$scope.url;
      }
      videoID = this.getVideoID(url);
      playlistID = this.getPlaylistID(url);
      console.log("" + videoID + ", " + playlistID);
      request = this.$http.get("http://gdata.youtube.com/feeds/api/playlists/" + playlistID + "?v=2&alt=json");
      return request.then((function(_this) {
        return function(res) {
          _this.playlist = new Playlist(res.data);
          _this.$scope.playlist = _this.playlist;
          return _this.playNextVideo();
        };
      })(this));
    };

    ParserController.prototype.playPreviousVideo = function() {
      return this.playVideoWithIndex(this.currentPlayingIndex - 1);
    };

    ParserController.prototype.playNextVideo = function() {
      return this.playVideoWithIndex(this.currentPlayingIndex + 1);
    };

    ParserController.prototype.playVideoWithIndex = function(index) {
      var video;
      video = new Video(this.playlist.entry[index]);
      if (!video) {
        return;
      }
      this.currentPlayingIndex = index;
      return this.playVideo(video);
    };

    ParserController.prototype.playVideo = function(video) {
      return this.getMp4Urls(video, (function(_this) {
        return function(urls) {
          var fileUrl;
          fileUrl = urls[0];
          console.log(fileUrl);
          if (!fileUrl) {
            return;
          }
          _this.player.src({
            type: 'video/mp4',
            src: fileUrl
          });
          return _this.player.play();
        };
      })(this));
    };

    ParserController.prototype.getMp4Urls = function(video, callback) {
      var request;
      request = this.$http.get("/parse?url=" + (encodeURIComponent(video.link)));
      this.$scope.busy = true;
      return request.then((function(_this) {
        return function(result) {
          _this.$scope.busy = false;
          return callback(result.data.urls);
        };
      })(this));
    };

    ParserController.prototype.downloadMp4 = function(video) {
      return this.getMp4Urls(video, (function(_this) {
        return function(urls) {
          return window.downloadFile(urls[0]);
        };
      })(this));
    };

    ParserController.prototype.getVideoID = function(url) {
      var match;
      match = url.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/);
      if (match && match[2].length === 11) {
        return match[2];
      }
    };

    ParserController.prototype.getPlaylistID = function(url) {
      var match;
      match = url.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|list=)([^#\&\?]*).*/);
      if (match && match[2]) {
        return match[2];
      }
    };

    return ParserController;

  })();

  app = angular.module('noTube');

  app.controller('ParserController', ['$scope', '$http', '$log', '$sce', ParserController]);

  app.controller('FacebookManager', ['$scope', '$http', 'Facebook', FacebookManager]);

}).call(this);
