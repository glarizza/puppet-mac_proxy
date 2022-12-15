mac_proxy_bypassdomains { 'Ethernet':
  ensure  => 'present',
  domains => ['www.garylarizza.com','*.puppetlabs.com','10.13.1.3/24'],
}
