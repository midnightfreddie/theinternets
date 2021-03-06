// In reply to https://www.reddit.com/r/angularjs/comments/3ye90u/how_to_pass_a_php_variable_to_angularjs/
/*
  Poster is trying to submit a filename in a POST request from Angular to a
  PHP servlet that seems to return a base64-encoded image file.
  Below is adapted from his code and untested, but I changed:
  - the Content-Type
  - .success() and .error() to .then() because deprecated
  - made success and error functions accept result as a parameter
  - assigned result.data to a variable which should be the data poster needs
*/


$scope.MakeGray_Button = function(){
  if ($scope.imageUrl) {
    var MakeGray_Form = new FormData();
    MakeGray_Form.append("FileName", $scope.imageUrl);

    var options = {
      method : "POST",
      url    : "../opencv/MakeGray/MakeGray.php",
      data   : MakeGray_Form,
      transformRequest: angular.identity,
      headers: {'Content-Type': "application/x-www-form-urlencoded"}
    };

    $http(options)
      .then(HttpSuccess, HttpError);
  }
  else{
      alert("Please upload an image");
  }

  var HttpSuccess = function (result) {
    // code if success
    $scope.base64FromPhp = result.data;
  }

  var HttpError = function (result) {
    // code if error
      console.log(result.status);
  }
}
