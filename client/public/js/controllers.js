(function() {
  var ParserController, Playlist, Video, app;

  app = angular.module('noTube');

  Video = (function() {
    function Video(obj) {
      this.videoID = obj["media$group"]["yt$videoid"]["$t"];
      this.link = "http://www.youtube.com/v/" + this.videoID;
      this.duration = +obj["media$group"]["media$content"][0]["duration"];
      this.title = obj["title"]["$t"];
      this.image = obj["media$group"]["media$thumbnail"][1];
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
    function ParserController($scope, $http, $log, $sce) {
      this.$scope = $scope;
      this.$http = $http;
      this.$log = $log;
      this.$sce = $sce;
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
      url = this.$scope.url;
      videoID = this.getVideoID(url);
      playlistID = this.getPlaylistID(url);
      console.log("" + videoID + ", " + playlistID);
      request = this.$http.get("http://gdata.youtube.com/feeds/api/playlists/" + playlistID + "?v=2&alt=json");
      return request.then((function(_this) {
        return function(result) {
          _this.playlist = new Playlist(result.data);
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
      var request;
      request = this.$http.get("/parse?url=" + (encodeURIComponent(video.link)));
      this.$scope.busy = true;
      return request.then((function(_this) {
        return function(result) {
          var fileUrl;
          _this.$scope.busy = false;
          fileUrl = result.data.urls[0];
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

  app.controller('ParserController', ['$scope', '$http', '$log', '$sce', ParserController]);

}).call(this);
