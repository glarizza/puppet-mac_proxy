Puppet::Type.newtype(:mac_auto_proxy) do
  desc "Puppet type that models an automatic proxy URL on OS X"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Interface name - currently must be 'friendly' name (e.g. Ethernet)"
  end

  newproperty(:proxy_server) do
    desc "Proxy Server setting for the interface"
  end
end

