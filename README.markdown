## OS X Proxy Puppet Module

This module contains all the files necessary for managing the following with Puppet:

* FTP Proxy server/port
* Web Proxy server/port
* Gopher Proxy server/port
* Secure Proxy server/port
* Streaming Proxy server/port
* Socks Proxy server/port
* Auto Proxy URL
* Proxy bypass domains

## How to use

* Install the module in your Puppet modulepath (If you don't know your main Puppet modulepath, you can find it with `sudo puppet config print modulepath`
* Discover all resources with `sudo puppet resource mac_web_proxy` (or appropriate proxy type)
* Declare and enforce configuration like you would normally with Puppet


## Puppet Types

* mac_web_proxy
* mac_ftp_proxy
* mac_gopher_proxy
* mac_secure_proxy
* mac_socks_proxy
* mac_auto_proxy
* mac_proxy_bypassdomains


## Declaring a proxy resource

The web, ftp, gopher, secure, and socks proxy types are all declared similarly and use the same properties/parameters:

    mac_web_proxy { 'Ethernet':
      ensure       => present,
      proxy_server => 'proxy.puppetlabs.com',
      proxy_port   => '8080'
    }

The auto proxy only accepts a `proxy_server` property, and does not accept a `proxy_port` property:

    mac_auto_proxy { 'Ethernet':
      ensure       => present,
      proxy_server => 'auto.puppetlabs.com',
    }

The `mac_proxy_bypassdomains` type accepts an array for the domain property and sets the domains that should bypass the proxies for that network interface:

    mac_proxy_bypassdomains { 'Ethernet':
      domains => ['*.puppetlabs.com', '10.13.1.3/24', 'www.garylarizza.com'],
    }




