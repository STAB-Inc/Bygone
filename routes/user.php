<?php 
  $file = 'users.json';
  if (!file_exists($file)) {
    fopen($file, 'w') or die('err');
  };

  if(isset($_REQUEST['new']))
  {
    echo $_POST['username'];
    $users = getUsers($file);
    $userData['id'] = uniqid();
    $userData['username'] = $_POST['username'];
    $userData['password'] = $_POST['password'];
    array_push($users, $userData);
    file_put_contents($file, json_encode($users));
  };

  function getUsers($file) {
    return json_decode(file_get_contents($file), true);
  };

?>