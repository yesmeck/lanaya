// Generated by CoffeeScript 1.6.3
(function() {
  var Lanaya;

  Lanaya = (function() {
    function Lanaya() {
      this.refresh();
      this.subscribe();
    }

    Lanaya.prototype.subscribe = function() {
      if (typeof WebSocket !== "undefined" && WebSocket !== null) {
        return this.subscribeWebSocket();
      } else {
        return this.subscribePoll();
      }
    };

    Lanaya.prototype.subscribeWebSocket = function() {
      var secure, uri,
        _this = this;
      secure = window.location.scheme === 'https';
      uri = "" + (secure ? 'wss' : 'ws') + "://" + window.location.host + "/interactions";
      this.websocket = new WebSocket(uri);
      return this.websocket.onmessage = function(event) {
        return _this.addInteraction($.parseJSON(event.data));
      };
    };

    Lanaya.prototype.subscribePoll = function() {
      var _this = this;
      if (this.refreshInterval == null) {
        return this.refreshInterval = setInterval((function() {
          return _this.refresh();
        }), 1000);
      }
    };

    Lanaya.prototype.refresh = function() {
      var _this = this;
      return $.getJSON('/interactions', function(interactions) {
        return $.each(interactions, function(i, interaction) {
          if (!_this.haveInteraction(interaction)) {
            return _this.addInteraction(interaction);
          }
        });
      });
    };

    Lanaya.prototype.addInteraction = function(interaction) {
      return console.log(interaction);
    };

    return Lanaya;

  })();

  jQuery(function() {
    return window.Lanaya = new Lanaya;
  });

}).call(this);