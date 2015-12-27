// In reply to https://www.reddit.com/r/angularjs/comments/3ye90u/how_to_pass_a_php_variable_to_angularjs/

$scope.MakeGray_Button = function(){
    if ($scope.imageUrl) {
        var MakeGray_Form = new FormData();
        MakeGray_Form.append("FileName", $scope.imageUrl);
        $http({
          method : "POST",
          url    : "../opencv/MakeGray/MakeGray.php",
          data   : MakeGray_Form,
          transformRequest: angular.identity,
          headers: {'Content-Type': "application/x-www-form-urlencoded"}
        })
          .then(function(result){
              // code if success
             var base64FromPhp = result.data;
            },
            function(result){
              // code if error
                console.log(result.status);
            }
          );
    }
    else{
        alert("Please upload an image");
    }
}
