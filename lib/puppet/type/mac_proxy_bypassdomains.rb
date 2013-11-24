Puppet::Type.newtype(:mac_proxy_bypassdomains) do
  desc "Puppet type that models bypass domains for a network interface on OS X"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Interface name - currently must be 'friendly' name (e.g. Ethernet)"
  end

  newproperty(:domains, :array_matching => :all) do
    desc "Domains which should bypass the proxy"
    def insync?(is)
      is.sort == should.sort
    end
  end
end

