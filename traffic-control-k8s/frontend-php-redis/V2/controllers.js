var redisApp = angular.module('redis', ['ui.bootstrap']);

/**
 * Constructor
 */
function RedisController() {}

RedisController.prototype.onRedis = function() {
    this.newMessage = this.scope_.msg
    this.scope_.redisResponse = "Sending...";
    this.scope_.pending.push(this.newMessage);
    this.scope_.msg = "";
    var value = this.scope_.messages.join() + "," + this.newMessage;
    this.http_.get("guestbook.php?cmd=set&key=messages&value=" + value)
            .success(angular.bind(this, function(data) {
                this.scope_.redisResponse = "Updated.";
                this.scope_.messages.push(this.newMessage);
                this.scope_.pending = [];
            }));
};

redisApp.controller('RedisCtrl', function ($scope, $http, $location) {
        $scope.redisResponse = "Loading...";
        $scope.controller = new RedisController();
        $scope.controller.scope_ = $scope;
        $scope.controller.location_ = $location;
        $scope.controller.http_ = $http;
        $scope.pending = [];

        $scope.controller.http_.get("guestbook.php?cmd=get&key=messages")
            .success(function(data) {
                console.log(data);
                $scope.messages = data.data.split(",");
                $scope.redisResponse = " ";
            });
});

