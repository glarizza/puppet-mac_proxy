class Puppet::Provider::MacProxy < Puppet::Provider
  # This is a helper library class that's shared by all the Mac proxy types.
  # Inside this class are all the methods necessary to 'do the work' for the
  # types - all the providers for those types need to do are inherit from this
  # base class and define a method called 'self.get_proxy_type' that returns
  # the symbolized value for the type of proxy that's being declared.

  def self.proxy_mapping
  # This method returns a hash mapping the proxy_type with the arguments
  # necessary for the `networksetup` binary. The 'auto' proxy type is different
  # because it doesn't take a port and only takes a URL.
    {
      :web =>
      {
        'get_argument'    => '-getwebproxy',
        'set_argument'    => '-setwebproxy',
        'enable_argument' => '-setwebproxystate',
      },
      :ftp =>
      {
        'get_argument'    => '-getftpproxy',
        'set_argument'    => '-setftpproxy',
        'enable_argument' => '-setftpproxystate',
      },
      :gopher =>
      {
        'get_argument'    => '-getgopherproxy',
        'set_argument'    => '-setgopherproxy',
        'enable_argument' => '-setgopherproxystate',
      },
      :secure =>
      {
        'get_argument'    => '-getsecurewebproxy',
        'set_argument'    => '-setsecurewebproxy',
        'enable_argument' => '-setsecurewebproxystate',
      },
      :socks =>
      {
        'get_argument'    => '-getsocksfirewallproxy',
        'set_argument'    => '-setsocksfirewallproxy',
        'enable_argument' => '-setsocksfirewallproxystate',
      },
      :streaming =>
      {
        'get_argument'    => '-getstreamingproxy',
        'set_argument'    => '-setstreamingproxy',
        'enable_argument' => '-setstreamingproxystate',
      },
      :auto =>
      {
        'get_argument'    => '-getautoproxyurl',
        'set_argument'    => '-setautoproxyurl',
        'enable_argument' => '-setautoproxystate',
      }
    }
  end

  def initialize(value={})
  # The @property_flush variable is necessary for the provider to destroy, or
  # ensure absent, the instance. All other initialization can be left to the
  # parent classes.
    super(value)
    @property_flush = {}
  end

  def self.get_list_of_interfaces
  # This method returns an array of all 'Friendly' interface names (a la
  # 'Ethernet' or 'FireWire').
    interfaces = networksetup('-listallnetworkservices').split("\n")
    interfaces.shift
    interfaces.sort
  end

  def self.instances
  # self.instances returns all instances of the resource type that are
  # discovered on the system.  The self.instances method is used by `puppet
  # resource`, and MUST be implemented for `puppet resource` to work. The
  # self.instances method is also frequently used by self.prefetch (which is
  # also the case for this provider class).
    interfaces = get_list_of_interfaces
    array_of_interfaces = interfaces.collect do |int|
      proxy_properties = get_proxy_properties(int, get_proxy_type)
      new(proxy_properties)
    end
    array_of_interfaces
  end

  def self.prefetch(resources)
  # Prefetching is invoked when managing a resource with `puppet agent`,
  # `puppet apply`, or using `puppet resource` to change a resource from the
  # command line. The self.prefetch method accepts a hash of all managed
  # resources for the mac proxy types (i.e. all resources of this type that
  # are in the catalog). The method also populates the @property_hash instance
  # variable with property values for each managed resource, and
  # @property_hash can be used by all provider methods (i.e. all methods that
  # DON'T begin with 'self.'). In this case (as is the case with most
  # prefetching methods), we're using self.instances to discover all property
  # values.
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def self.get_proxy_properties(int, proxy_type)
  # This method will return a hash containing all the web proxy 'IS' value
  # properties for a provided interface
    interface_properties = {}

    begin
      output = networksetup([proxy_mapping[proxy_type]['get_argument'], int])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug "#get_proxy_properties had an error -> #{e.inspect}"
      return {}
    end

    # The auto proxy is different in that it only takes a URL (or
    # resource[:proxy_server]) argument and nothing else. This is handled here.
    if proxy_type != :auto
      output_array = output.split("\n")
      output_array.each do |line|
        line_values = line.split(':')
        line_values.last.strip!
        case line_values.first
        when 'Enabled'
          interface_properties[:ensure] = line_values.last == 'No' ? :absent : :present
        when 'Server'
          interface_properties[:proxy_server] = line_values.last.empty? ? nil : line_values.last
        when 'Port'
          interface_properties[:proxy_port] = line_values.last == '0' ? nil : line_values.last
        when 'Authenticated Proxy Enabled'
          interface_properties[:proxy_authenticated] = line_values.last == '0' ? nil : line_values.last
        end
      end
    else
      output_array = output.split("\n")
      output_array.each do |line|
        line_values = line.split(':')
        line_values.last.strip!
        case line_values.first
        when 'URL'
          interface_properties[:proxy_server] = line_values.last == '(null)' ? nil : line_values.last
        when 'Enabled'
          interface_properties[:ensure] = line_values.last == 'No' ? :absent : :present
        end
      end
    end

    # All proxy types share these two properties
    interface_properties[:provider]             = :ruby
    interface_properties[:name]                 = int.downcase
    interface_properties
  end

  def set_proxy(proxy_type)
  # The set_proxy method wraps the process of setting proxy values for
  # an interface.
    if @property_flush[:ensure] == :absent
        networksetup([self.class.proxy_mapping[proxy_type]['enable_argument'], resource[:name], 'off'])
        return
    end

    # Parameter Check
    if proxy_type != :auto
      if (resource[:proxy_server].nil? or resource[:proxy_port].nil?)
        # TODO:  THIS DOES NOT FAIL THE RUN!!! FIX THIS!
        raise Puppet::Error, "Proxy types other than 'auto' require both a proxy_server and proxy_port setting"
      end
      if resource[:proxy_authenticated] != :true
        networksetup(
          [
            self.class.proxy_mapping[proxy_type]['set_argument'],
            resource[:name],
            resource[:proxy_server],
            resource[:proxy_port]
          ]
        )
      else
        networksetup(
          [
            self.class.proxy_mapping[proxy_type]['set_argument'],
            resource[:name],
            resource[:proxy_server],
            resource[:proxy_port],
            'on',
            resource[:authenticated_username],
            resource[:authenticated_password]
          ]
        )
      end
    else
      if resource[:proxy_server].nil?
        raise Puppet::Error, "Proxy types of 'auto' require a proxy_server setting"
      end
      networksetup(
        [
          self.class.proxy_mapping[proxy_type]['set_argument'],
          resource[:name],
          resource[:proxy_server]
        ]
      )
    networksetup([self.class.proxy_mapping[proxy_type]['enable_argument'], resource[:name], 'on'])
    end
  end

  def flush
  # The flush provider method is invoked ONCE per resource whenever any of
  # the resource's properties need to be synchronized/changed. It allows for
  # setting all properties of a resource at once, so gives you a bit of
  # a performance boost (instead of invoking individual setter methods for
  # every property).  Flush allows you to make a single system call that will
  # set multiple property values - but in this case, because networksetup
  # requires multiple arguments in order to set the multiple properties for
  # a proxy, we are only going to make a single call for each resource that
  # needs to be changed.
    if @property_flush
      set_proxy(get_proxy_type)
    end
    # Collect the resources again once they've been changed (that way `puppet
    # resource` will show the correct values after changes have been made).
    @property_hash = self.class.get_proxy_properties(resource[:name], get_proxy_type)
  end

  def create
    set_proxy(get_proxy_type)
  end
end

