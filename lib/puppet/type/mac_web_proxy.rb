Puppet::Type.newtype(:mac_web_proxy) do
  desc "Puppet type that models a network interface on OS X"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Interface name - currently must be 'friendly' name (e.g. Ethernet)"
    #munge do |value|
    #  value.downcase
    #end
    #def insync?(is)
    #  is.downcase == should.downcase
    #end
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

  #newproperty(:proxy_bypass_domains, :array_matching => :all) do
  #  desc "Domains which should bypass the proxy"

  #  def insync?(is)
  #    is.sort == should.sort
  #  end
  #end

end
