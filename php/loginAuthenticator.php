<?php
echo "Starting Session";
session_start();
include 'db.php';

//$userResult = pg_query($db, "SELECT username FROM member WHERE username='$_POST[uname]' AND password = '$_POST[psw]'");
//$isAdminResult = pg_query($db, "SELECT isAdmin FROM member WHERE username = '$_POST[uname]' AND password = '$_POST[psw]'");

// if unauthorized, allow for login
if( isset($_POST['Login'])) {
	if(isset( $_POST['uid'] ) && isset( $_POST['pw'])){
	  // check user/pass against database, .htaccess file, etc.
	  $_SESSION['username'] = $_POST[uid];
	  $_SESSION['isLoggedIn'] = true;
	  $userResult = pg_query($db, "SELECT * FROM member WHERE username = '$_POST[uid]' AND password = '$_POST[pw]'");
	  $rowResult = pg_num_rows($userResult);
	  if($rowResult == 0){
			echo "<script type='text/javascript'>alert('Wrong Username or Password'); window.location='../public/login.php';</script>";
	  }
	  else{
		  header("location:../public/home.php");
	  }
	}
}
?>
