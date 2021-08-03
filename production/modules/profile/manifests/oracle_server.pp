class profiles::oracle_server (
 $version,
 $zip_extract                             = false,
 $remote_file                             = false,
 $database_type,
 $oracle_base,
 $oracle_home,
 $user,
 $group,
 $group_install,
 $group_oper,
 $download_dir,
 $bash_profile,
 $oracle_rdbms_server_preinstall_package,
)
{

  package { $oracle_rdbms_server_preinstall_package:
    ensure => present,
  }

  oradb::installdb{ "${version}_${::kernel}-${::architecture}":
    version                   => $version,
    zip_extract               => $zip_extract,
    remote_file               => $remote_file,
    database_type             => $database_type,
    oracle_base               => $oracle_base,
    oracle_home               => $oracle_home,
    user                      => $user,
    group                     => $group,
    group_install             => $group_install,
    group_oper                => $group_oper,
    download_dir              => $download_dir,
    bash_profile              => $bash_profile,
    require                   => Package[$oracle_rdbms_server_preinstall_package],
  }

}
