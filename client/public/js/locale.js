(function() {
  var app;

  app = angular.module('locale', ['constants']);

  app.factory("localeTW", [
    'Constants', function(constants) {
      return {
        shipment: function(code) {
          switch (code) {
            case constants.SHIPMENT_FACE:
              return '面交';
            case constants.SHIPMENT_POST:
              return '郵寄';
            case constants.SHIPMENT_HOME:
              return '宅配/貨運';
            case constants.SHIPMENT_711:
              return '7-11取貨';
            case constants.SHIPMENT_FAMILYMART:
              return '全家取貨';
            case constants.SHIPMENT_Oversea:
              return '海外';
          }
        },
        conditions: function(code) {
          switch (code) {
            case constants.CONDITION_99:
              return '幾乎全新';
            case constants.CONDITION_90:
              return '9成新';
            case constants.CONDITION_80:
              return '8成新';
            case constants.CONDITION_70:
              return '7成新';
            case constants.CONDITION_50:
              return '5成新';
          }
        },
        county: function(code) {
          switch (code) {
            case constants.CountyTaipeiCity:
              return '台北市';
            case constants.CountyNewTaipeiCity:
              return '新北市';
            case constants.CountyKeelungCity:
              return '基隆市';
            case constants.CountyYilan:
              return '宜蘭';
            case constants.CountyTaoyuan:
              return '桃園';
            case constants.CountyHsinchuCity:
              return '新竹市';
            case constants.CountyHsinchu:
              return '新竹';
            case constants.CountyMiaoli:
              return '苗栗';
            case constants.CountyTaichungCity:
              return '台中市';
            case constants.CountyChanghua:
              return '彰化';
            case constants.CountyNantou:
              return '南投';
            case constants.CountyChiayiCity:
              return '嘉義市';
            case constants.CountyChiayi:
              return '嘉義';
            case constants.CountyYunlin:
              return '雲林';
            case constants.CountyTainanCity:
              return '台南市';
            case constants.CountyKaohsiungCity:
              return '高雄市';
            case constants.CountyPingtung:
              return '屏東';
            case constants.CountyHualien:
              return '花蓮';
            case constants.CountyTaitung:
              return '台東';
            case constants.CountyPenghu:
              return '澎湖';
            case constants.CountyMazu:
              return '媽祖';
            case constants.CountyKinmen:
              return '金門';
          }
        }
      };
    }
  ]);

}).call(this);
