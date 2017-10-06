<?php

  $file = 'users.json';

  if (!file_exists($file)) {
    fopen($file, 'w') or die('err');
  }
  
  if($_POST['method'] == 'new') {
    $users = getUsers($file);
    $userData['id'] = uniqid();
    $userData['username'] = $_POST['username'];
    $userData['password'] = $_POST['password'];
    foreach ($users as $user) {
      if ($userData['username'] == $user['username']) {
        returnMsg('error', 'Username already taken');
        return 0;
      }
    } 
    array_push($users, $userData);
    file_put_contents($file, json_encode($users));
    setcookie('activeUserId', $userData['id'], time() + (86400 * 30), '/');
    returnMsg('success', 'success');
  } 

  elseif ($_POST['method'] == 'getActiveUser') {
    if (!empty($_COOKIE['activeUserId'])) {
      returnMsg('success', $_COOKIE['activeUserId']);
    } else {
      returnMsg('noUser', 'noUser');
    }
  }

  elseif ($_POST['method'] == 'getUserData') {
    echo json_encode(getUserDataById($_POST['id']));
  }

  elseif ($_POST['method'] == 'logout') {
    setcookie('activeUserId', '', time() - 3600, '/');
    returnMsg('success', 'success');
  }

  function getUserDataById($id) {
    global $file;
    foreach (getUsers($file) as $user) {
      if ($id == $user['id']) {
        return $user;
      }
    } 
  }

  function getUsers($file) {
    return json_decode(file_get_contents($file), true);
  }

  function returnMsg($status, $msg) {
    $res['status'] = $status;
    $res['message'] = $msg;
    echo json_encode($res);
  }

?>