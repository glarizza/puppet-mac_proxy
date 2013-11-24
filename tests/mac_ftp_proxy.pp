mac_ftp_proxy { 'FireWire':
  ensure       => 'present',
  proxy_port   => '1234',
  proxy_server => 'ftp.test.proxy',
}

mac_ftp_proxy { 'Ethernet':
  ensure => 'absent',
}
