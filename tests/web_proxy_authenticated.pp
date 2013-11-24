mac_web_proxy { 'FireWire':
  ensure                 => 'present',
  proxy_port             => '8140',
  proxy_server           => 'secure.proxy.vm',
  proxy_authenticated    => true,
  authenticated_username => 'newgary',
  authenticated_password => 'secret',
}
