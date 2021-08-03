class helloworld::example {
    file { '/tmp/example.txt':
    owner  => 'root',
    group  => 'root',
    mode    => '0644',
    content => "hello, world!\n",
    }
}

