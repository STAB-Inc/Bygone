<?php
  $file = 'users.json';

  if (!file_exists($file)) {
    fopen($file, 'w') or die('err');
  }

  if(isset($_POST['method']) == 'new') {
    $users = getUsers($file);
    $userData['id'] = uniqid();
    $userData['username'] = $_POST['username'];
    $userData['password'] = $_POST['password'];
    foreach ($users as $user) {
      if ($userData['username'] == $user['username']) {
        returnMsg('error', 'Username already exists');
        return 0;
      }
    } 
    array_push($users, $userData);
    file_put_contents($file, json_encode($users));
    $_SESSION['activeUser'] = $userData['id'];
    returnMsg('success', 'success');
  } 

  elseif (isset($_POST['method']) == 'getActiveUser') {
    return $_SESSION['activeUser'];
  }
  
  function getUsers($file) {
    return json_decode(file_get_contents($file), true);
  }

  function returnMsg($status, $msg) {
    $res['status'] = $status;
    $res['errorMsg'] = $msg;
    echo json_encode($res);
  }

?>