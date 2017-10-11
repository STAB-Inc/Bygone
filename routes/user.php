<?php
session_start();
$connection = mysqli_connect('localhost','Admin','Assasindie');
if (!$connection) {
    die("Database connection failed: " . mysqli_error());
}

$db_select = mysqli_select_db($connection, 'whitetracker');
if (!$db_select) {
    die("Database selection failed: " . mysqli_error());
}

?>
	<!-- PHP login verification -->
<?php
	global $_SQL_WEBSITE_LOGIN_USER;
	global $_SQL_WEBSITE_LOGIN_PASS;
	global $PassVerified;

	$_SQL_WEBSITE_LOGIN_USER = $_POST['UserName'];
	$_SQL_WEBSITE_LOGIN_PASS = $_POST['Password'];
	$_SESSION["UserName"] = $_SQL_WEBSITE_LOGIN_USER;
	
	$sql= "SELECT `UserName`, `Pass` FROM `login` WHERE UserName= '".$_SQL_WEBSITE_LOGIN_USER."' AND pass = '".$_SQL_WEBSITE_LOGIN_PASS."'";
	$result=mysqli_query($connection ,$sql) or die (mysqli_error($connection)); 
	$count=mysqli_num_rows($result);
		
	$sql_user = "SELECT `User_Name`, `Pass_word` FROM `normal_login` WHERE User_Name= '".$_SQL_WEBSITE_LOGIN_USER."' AND pass_word = '".$_SQL_WEBSITE_LOGIN_PASS."'";
	$HashPassSQL = "SELECT `Pass_word` FROM `normal_login` WHERE User_Name = '".$_SQL_WEBSITE_LOGIN_USER."'";
	 
	$HashPass = mysqli_query($connection, $HashPassSQL) or die (mysqli_error($connection));	
	if(mysqli_num_rows($HashPass)>0){
    $row = mysqli_fetch_array($HashPass);
	}

	
	$_SESSION['LoginFailed'] = 1;
	//Checking if logged in as admin
	if($count==	1){
	$_SESSION["Logged_in_Admin"] = "yes";
	$_SESSION["LoginFailed"] = "0";
	$_SESSION["Admin_Login_Failed"] = "0";	
	}else{
	$_SESSION["Admin_Login_Failed"] = "1";
	}
	
	
	//verify Hash
	if(password_verify($_SQL_WEBSITE_LOGIN_PASS, $row[0])){
	$PassVerified ="1";
	}
	$result_user =mysqli_query($connection, $sql_user) or die (mysqli_error($connection)); 
	$count_user=mysqli_num_rows($result_user);
	
	//checking if logged in as user
	if($count_user = "1" and $PassVerified == "1"){
 	$_SESSION["Logged_in_User_failed"] = "0";
	$_SESSION['LoginFailed'] = "0";
	}
	
	
	
	?> 
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">	
	<?php if ($_SESSION['LoginFailed'] == "1") { ?><meta http-equiv="refresh" content="0; url=Login.php" /> <?php } ?>
	<?php if ($_SESSION["Logged_in_User_failed"] == "0") { ?> <meta http-equiv = "refresh" content = "0; url = My_Profile.php" /> <?php } ?>
	<?php if ($_SESSION["Admin_Login_Failed"] == "0") { ?> <meta http-equiv = "refresh" content = "0; url = Admin_Profile.php" /> <?php } ?>
    <link rel="shortcut icon" href="../../docs-assets/ico/favicon.png">

    <title>  <?php if ($_SESSION["Logged_in_User"] = "yes"){ echo "Logged in as " . $_POST['UserName'];} else { echo "Login Failed!"	;} ?> </title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.css" rel="stylesheet">


    <!-- CSS -->
    <link href="css/main.css" rel="stylesheet">

    <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="js/hover.zoom.js"></script>
    <script src="js/hover.zoom.conf.js"></script>

  </head>

  <body>

    <!-- Static navbar -->
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
<span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.php">White Bag Tracker</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">            
                       <?php if($_SESSION["LoginFailed"] == "0"){ ?><li><a href="My_Profile.php">My Profile</a></li><?php } else { ?> <li><a href="Login.php">Log in</a></li> <?php } ?>
            <li><a href="contact.php">Contacts</a></li>
			<li><a href ="UpdateHistory.php"> Update History </a> </li>
			<?php if($_SESSION["LoginFailed"] == "0"){ ?> <li> <a href = "logout.php"> Logout </a></li> <?php }?>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </div>

	<!-- +++++ Main +++++ -->
	<div id="ww">
	    <div class="container">
			<div class="row">
				<div class="col-lg-8 col-lg-offset-2 centered">
					<!-- <img src="img/AlexPic.jpg" alt="Stanley"> -->
					<h1>Login Failed</h1>
				</div><!-- /col-lg-8 -->
			</div><!-- /row -->
	    </div> <!-- /container -->
	</div><!-- /ww -->
	<!-- PHP login verification -->
	<?php 
	if($count==1){
	?> 
	<div id="ww">
	    <div class="container">
			<div class="row">
				<div class="col-lg-8 col-lg-offset-2 centered">	
					<form action ="Add_Donation.php" method = "post">
					<input type = "submit" Value = "Add Donator" id = "btn"> </input> </br> </br>
					</form>
					<form action ="Add_Admin.php" method = "post">
					<input type = "submit" Value = "Add new Admin" id = "btn"> </input> </br> </br>
					</form>
					<form action ="Delete_Admin.php" method = "post">
					<input type = "submit" Value = "Delete Admin" id = "btn"> </input> </br> </br>
					</form>
					<form action = "Delete_Donation.php" method = "post">
					<input type = "submit" Value = "Delete Donation" id ="btn"> </input> </br> </br>
					</form>
					<form action = "Delete_User.php" method = "post">
					<input type = "submit" Value = "Delete User" id = "btn"> </input> </br> </br>
					</form>
				</div>
			</div>
	    </div> 
	</div>
	
	<?php
	}else{
	$SESSION['Logged_in'] = "No";
	?>
	<form action = "Login_Complete.php" method = "post">
		<div id="ww">
	    <div class="container">
			<div class="row">
				<div class="col-lg-8 col-lg-offset-2 centered">
					Sorry That was Incorrect! </br> </br> </br> </br>
					UserName <input type = "text" name = "UserName" style = "width : 200px" required> </input> </br> </br>
					Password <input type = "text" name = "Password" style="width : 200px" required >  </input> </br> </br>
							<input type = "submit" name = "submit" value = "Enter"/> 
				</div><!-- /col-lg-8 -->
			</div><!-- /row -->
	    </div> <!-- /container -->
	</div><!-- /ww -->
	
	</form>
	<?php
	}
	
	?>
	<!-- Bottom Footer -->
	
	<div id="footer">
		<div class="container">
			<div class="row">
				<div class="col-lg-4">
					<a href = "Contact.php"> Contact Us </a><br/>
				</br>
				</br>
				</br>
				</br>
				</div><!-- /col-lg-4 -->
				
			</div>
		
		</div>
	</div>
	

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="assets/js/bootstrap.min.js"></script>
  </body>
</html>
