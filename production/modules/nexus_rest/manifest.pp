# nexus_generic_settings { 'crowd':
#   api_url_fragment => '/service/siesta/crowd/config',
#   merge            => true,
#   settings_hash    => {
#         "applicationName"=>"b"
#   }
# }



nexus_crowd_settings { 'current':
    application_name => "b",
    application_password => 'present',
    application_password_value => "value",
    crowd_server_url => 'http://crowd-server.com',
    http_timeout => 100
}