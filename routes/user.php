<?php 
  $file = 'users.json';
  if (!file_exists($file)) {
    fopen($file, 'w') or die('err');
  };
  if(isset($_REQUEST['new']))
  {
    echo $_POST['username'];
    $userData['id'] = uniqid();
    $userData['username'] = $_POST['username'];
    $userData['password'] = $_POST['password'];
    file_put_contents($file, json_encode($userData));
  }
?>