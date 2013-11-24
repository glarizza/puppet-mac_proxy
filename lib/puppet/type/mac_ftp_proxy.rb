Puppet::Type.newtype(:mac_ftp_proxy) do
  desc "Puppet type that models an FTP proxy on OS X"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Interface name - currently must be 'friendly' name (e.g. Ethernet)"
  end

  newproperty(:proxy_server) do
    desc "Proxy Server setting for the interface"
  end

  newparam(:proxy_authenticated) do
    desc "Proxy Server setting for the interface"
    newvalues(:true, :false)
  end

  newproperty(:proxy_port) do
    desc "Proxy Server setting for the interface"
  end

end