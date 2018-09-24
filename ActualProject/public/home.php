<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">

<?php
	session_start();
	if (isset($_SESSION['isLoggedIn']) && $_SESSION['isLoggedIn'] == true) {
		echo "You're logged into the member's area " . $_SESSION['username'] . "!";
	} else {
		header("location:login.php");
	}
	$UNAME = $_SESSION['username'];	//retrieve USERNAME
	include 'db.php';
	$currentId = '0';

	//Get list of projects that are advertising
	$result = pg_query($db, "SELECT * FROM project a LEFT JOIN advertise b ON a.id = b.proj_id");
	$totalSize = pg_num_rows($result);
	echo "row size = $totalSize";
	$project = array();
	//extracts list from $result into 2d array
	$i=0;
	while($row = pg_fetch_assoc($result)){
		$project[$i] = $row;
		$i++;
	}
	//echo "hello";
	//echo $project[$i]['title'];
	//echo $project[$i]['entrepreneur'];
	if(!result) {
		echo "Unable to retrieve result";
	}


	//Loop through the rows then assign the value required into the list of project.

	//Using the proj_id, find the required Project Name and Description and category
	//Use this Example query: Replace $currentId with value obtained previously. Other details you may require are : start_date
	//$resultProjId = pg_query($db, "SELECT title, description, category FROM project WHERE id = $currentId");

	//Display the Project, Description, amt_needed, amt_raised, category, status through looping
?>
<html>
	<head>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js"></script>
		<style>
			a.logout {
				color: white;
			}
			card {
				padding-top: 15px;
			}
		</style>
	</head>
	  <form = "form-vertical" method="post" action="home.php">
	<body>
		<nav class="navbar navbar-expand-lg navbar-dark bg-dark py-0">
		  <div class="container">
			<div class="collapse navbar-collapse navMenu justify-content-between">
			  <div class="d-flex justify-content-end justify-content-lg-start pt-1 pt-lg-0">
				<div class="dropdown">
				  <button class="btn dropdown-toggle btn-dark btn-sm"  type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
					<img src="img/user.png" alt="user image" class="btn-image" width="60" height="40">
					<span>Welcome! <?php echo "$UNAME";?>
					</span>
				  </button>
				  <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
					<a class="dropdown-item" href="#">Profile</a>
				  </div>
				</div>
			  </div>
			  <div class="py-1 d-flex align-items-center justify-content-end">
				<ul class="navbar-nav d-flex flex-row">
				  <li class="nav-item">
					<a href="documentation/index.html" class="text-small nav-link px-2">Explore</a>
				  </li>
				  <li class="nav-item">
					<a href="documentation/changelog.html" class="text-small nav-link px-2">My Investments
					</a>
				  </li>
				  <?php
				  include 'db.php';
				  $queryUser = $_SESSION['username'];
				  $resultAdmin = pg_query($db, "SELECT * FROM member WHERE username = '$queryUser' AND is_admin = 1");
				  $rowAdmin = pg_num_rows($resultAdmin);
				  if($rowAdmin > 0){
					  echo '<li class="nav-item">';
					  echo '<a href="admin.php" class="text-small nav-link px-2">Admin';
					  echo '</a>';
					  echo '</li>';
				  }
				  ?>
				</ul>
				<button class="btn btn-primary btn-sm" name="logout"><a href="logout.php" class="logout">Logout</a></button>
			  </div>
			</div>
		  </div>
		</nav>
		<section class="pb-0">
		 <div class="container">
			<div class="row text-center mb-4">
			  <div class="col">
				<h2>Entrepreneur Projects</h2>
			  </div>
			</div>
			<div class="row">
				<?php foreach($project as $projectRow): ?>
					<?php echo "<script> console.log('Iterating project') </script>"; ?>
					  <div class="col-12 col-md-4" style="padding-top: 15px;">
						<div class="card">
						  <div class="card-body py-3">
							<h5><?php echo $projectRow['title'];?></h5>
							<div class="mb-4">
							  <p><?php echo $projectRow['description'];?></p>
							</div>
						  </div>
						  <div class="card-footer">
								<div class="d-flex align-items-center justify-content-between">
									<a href="#!" data-toggle="modal" data-target="#exampleModal"
										onClick="displayPopupInformation('<?php echo $projectRow['id'];?>',
																										 '<?php echo $projectRow['title'];?>',
																										 '<?php echo $projectRow['description'];?>',
																										 '<?php echo $projectRow['category'];?>',
																										 '<?php echo $projectRow['start_date'];?>',
																										 '<?php echo $projectRow['duration'];?>',
																										 '<?php echo $projectRow['amt_needed'];?>',
																										 '<?php echo $projectRow['amt_raised'];?>')">Invest</a>
								</div>
						  </div>
						</div>
					</div>
				<?php endforeach; ?>
				<!-- Modal Popup-->
				<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
					<div class="modal-dialog" role="document">
						<div class="modal-content">
							<div class="modal-header">
								<h5 class="modal-title" id="modalProjectTitle"></h5>
								<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">x</span></button>
							</div>
							<div class="modal-body">
								<p id="modalProjectDescription"></p>
							</div>
							<div class="modal-body">
								<p>Amount Needed: <span id="modalProjectAmtNeeded"></span></p>
								<p>Current Amount Raised: <span id="modalProjectAmtRaised"></span></p>
							</div>
							<div class="modal-footer">
								<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
								<button type="button" class="btn btn-primary" data-dismiss="modal">Invest</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		 </div>
		</section>

		<script>
			function displayPopupInformation(id, title, description, category, startDate, duration, amtNeeded, amtRaised) {
				console.log("Project id: " + id);
				document.getElementById("modalProjectTitle").innerHTML = title;
				document.getElementById("modalProjectDescription").innerHTML = description;
				document.getElementById("modalProjectAmtNeeded").innerHTML = amtNeeded;
				document.getElementById("modalProjectAmtRaised").innerHTML = amtRaised;
			}
		</script>
	</body>
</html>
