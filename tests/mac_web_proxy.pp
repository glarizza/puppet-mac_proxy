mac_web_proxy { 'FireWire':
  ensure               => 'present',
  proxy_server         => 'firewire.proxy.org',
  proxy_port           => '8190',
}

mac_web_proxy { 'Ethernet':
  ensure => 'absent',
}
