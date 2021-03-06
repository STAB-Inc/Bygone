<?php

  # Default file.
  $file = 'users.json';

  # Check if file exists.
  if (!file_exists($file)) {
    fopen($file, 'w') or die('err');
  }
  
  #Create a new user.
  if($_POST['method'] == 'new') {
    $users = getUsers($file);
    foreach ($users as $user) {
      if ($_POST['username'] == $user['username']) {
        returnMsg('error', 'Username already taken');
        return 0;
      }
    } 
    $userData['id'] = uniqid();
    $userData['username'] = $_POST['username'];
    $userData['password'] = hash('sha256', $_POST['password']);
    $userData['unlockables']['ch1'] = false;
    $userData['unlockables']['ch2'] = false;
    $userData['unlockables']['ch3'] = false; 
    $userData['unlockables']['ch4'] = false;
    $userData['scores']['g1'] = array();
    $userData['scores']['g2'] = array();
    $userData['scores']['g3'] = array();
    $userData['scores']['g4'] = array();
    $userData['collections'] = array();
    array_push($users, $userData);
    file_put_contents($file, json_encode($users));
    setcookie('activeUserId', $userData['id'], time() + (86400 * 30), '/');
    returnMsg('success', 'success');
  }

  #Login a user.
  elseif ($_POST['method'] == 'login') {
    global $file;
    foreach (getUsers($file) as $user) {
      if ($_POST['username'] == $user['username']) {
        if (hash('sha256', $_POST['password']) == $user['password']) {
          setcookie('activeUserId', $user['id'], time() + (86400 * 30), '/');
          returnMsg('success', 'success');
          return 0;
        } else {
          returnMsg('error', 'Incorrect Password');
          return 0;
        }
      }
    }
    returnMsg('error', 'User does not exist');
  }

  #Get the current logged user.
  elseif ($_POST['method'] == 'getActiveUser') {
    if (!empty($_COOKIE['activeUserId'])) {
      returnMsg('success', $_COOKIE['activeUserId']);
    } else {
      returnMsg('noUser', 'noUser');
    }
  }

  #Get user data by user id.
  elseif ($_POST['method'] == 'getUserData') {
    echo json_encode(getUserDataById($_POST['id']));
  }

  #Logs a user out.
  elseif ($_POST['method'] == 'logout') {
    setcookie('activeUserId', '', time() - 3600, '/');
    returnMsg('success', 'success');
  }

  #Deletes a user account.
  elseif ($_POST['method'] == 'deleteUser') {
    global $file;
    $users = getUsers($file);
    $updated = array();
    foreach ($users as $user) {
      if ($_COOKIE['activeUserId'] != $user['id']) {
        array_push($updated, $user);
      }
    }
    file_put_contents($file, json_encode($updated));
    setcookie('activeUserId', '', time() - 3600, '/');
    returnMsg('success', 'success');
  }

  #Completes a chapter.
  elseif ($_POST['method'] == 'chapterComplete') {
    global $file;
    $users = getUsers($file);
    foreach ($users as $index => $user) {
      if ($_COOKIE['activeUserId'] == $user['id']) {
        $users[$index]['unlockables']['ch' . $_POST['chapterId']] = true;
      }
    }
    file_put_contents($file, json_encode($users));
    returnMsg('success', 'success');
  }

  #Saves the score of a user.
  elseif ($_POST['method'] == 'saveScore') {
    global $file;
    $users = getUsers($file);
    if (!isset($_COOKIE['activeUserId'])) {
      returnMsg('error', 'You must be logged in to save');
    }
    else {
      foreach ($users as $index => $user) {
        if ($_COOKIE['activeUserId'] == $user['id']) {
          array_push($users[$index]['scores']['g' . $_POST['gameId']], [$_POST['value'], date('r')]);
        }
      }
      file_put_contents($file, json_encode($users));
      returnMsg('success', 'Your score has been saved.');
    }
  }

  #Adds a item to the user's collection.
  elseif ($_POST['method'] == 'saveItem') {
    global $file;
    $users = getUsers($file);
    if (!isset($_COOKIE['activeUserId'])) {
      returnMsg('error', 'You must be logged in to save');
    }
    else {
      foreach ($users as $index => $user) {
        if ($_COOKIE['activeUserId'] == $user['id']) {
          array_push($users[$index]['collections'], [$_POST['description'], $_POST['image']]);
        }
      }
      file_put_contents($file, json_encode($users));
      returnMsg('success', 'Successfully added to collection.');
    }
  }

  #Get all user data.
  elseif ($_POST['method'] == 'getAll') {
    global $file;
    $users = array();
    foreach (getUsers($file) as $user) {
      unset($user['password']);
      unset($user['collections']);
      unset($user['unlockables']);
      array_push($users, $user);
    }
    echo json_encode($users);
  }

  #Get user data by a given user id.
  function getUserDataById($id) {
    global $file;
    foreach (getUsers($file) as $user) {
      if ($id == $user['id']) {
        return $user;
      }
    }
  }

  #Get all user data.
  function getUsers($file) {
    return json_decode(file_get_contents($file), true);
  }

  #Returns the response to the request origin.
  function returnMsg($status, $msg) {
    $res['status'] = $status;
    $res['message'] = $msg;
    echo json_encode($res);
  }

?>