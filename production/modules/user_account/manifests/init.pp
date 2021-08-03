class user_account ($username = 'homer'){

  user { $username:
    ensure => present,
    uid    => '101',
    shell  => '/bin/bash',
    home   => "/home/$username",
  }
  $greetings = "have a great day!!!"
  file { '/tmp/user.txt':
    ensure  => file,
    content  => template("user_account/user-master-copy.erb"),
  }
}
