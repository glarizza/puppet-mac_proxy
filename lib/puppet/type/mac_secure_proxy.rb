Puppet::Type.newtype(:mac_secure_proxy) do
  desc "Puppet type that models a secure web proxy on OS X"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Interface name - currently must be 'friendly' name (e.g. Ethernet)"
    munge do |val|
      val.downcase
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:proxy_server) do
    desc "Proxy Server setting for the interface"
  end

  newparam(:authenticated_username) do
    desc "Username for proxy authentication"
  end

  newparam(:authenticated_password) do
    desc "Password for proxy authentication"
  end

  newproperty(:proxy_authenticated) do
    desc "Proxy Server setting for the interface"
    newvalues(:true, :false)
  end

  newproperty(:proxy_port) do
    desc "Proxy Server setting for the interface"
    newvalues(/^\d+$/)
  end
end

