require 'pathname'
dir = Pathname.new(__FILE__).parent
$LOAD_PATH.unshift(dir, dir + 'lib', dir + '../lib')
begin
  require 'win32ole'
rescue LoadError
end

module Mscs
  class Cluster
    #class Error < StandardError; end

    @@wmi_username = nil
    @@wmi_server = nil

    def self.initialize(server,username=nil)
      @@wmi_username = username
      @@wmi_server = server
    end

    def self.connectstring
      if @@wmi_username
        conn_str = "winmgmts:{impersonationLevel=delegate,authenticationLevel=pktPrivacy,authority=kerberos:#{@@wmi_username}}!\\\\#{@@wmi_server}\\root\\mscluster"
      else
        conn_str = "winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy}!\\\\#{@@wmi_server}\\root\\mscluster"
      end
    end

    def self.wmiconnect
      winmgmts = Mscs::Cluster.connectstring
      begin
        WIN32OLE.connect(winmgmts)
      rescue WIN32OLERuntimeError => err
        raise Error, err
      end
    end

		def self.state
      objWMIService = wmiconnect
      objClus = objWMIService.Get("MSCluster_Cluster")
      nodestate=objClus.ExecMethod_("GetNodeClusterState")
      case nodestate.ClusterState
        when 0 ; return 'ClusterStateNotInstalled'
        when 1 ; return 'ClusterStateNotConfigured'
        when 3 ; return 'ClusterStateNotRunning'
        when 19 ; return 'ClusterStateRunning'
      end
    end

    def self.nodename
      objWMIService = wmiconnect
      clustername=objWMIService.ExecQuery('select name from mscluster_node')
      return clustername.each.first.name
    end

    def self.create(cluster_config={})
      cluster_config.has_key?(:ClusterName) or raise 'requires ClusterName key'
      cluster_config.has_key?(:IPAddresses) or raise 'requires IPAddresses key'
      cluster_config.has_key?(:NodeNames) or raise 'requires NodeNames key'
      cluster_config.has_key?(:SubnetMasks) or raise 'requires SubnetMasks key'

      objWMIService = wmiconnect
      objClus = objWMIService.Get("MSCluster_cluster")
      objInParam= objClus.Methods_("CreateCluster").InParameters.SpawnInstance_()
      cluster_config.each do |key, value|
        key=key.to_s
        objInParam.Properties_.item(key).value = value
      end

      objoutparams = objClus.ExecMethod_("CreateCluster", objInParam)
    end

    def self.destroy
      objWMIService = wmiconnect
      cluster=objWMIService.ExecQuery("select * from MSCluster_Cluster")
      cluster.each.first.DestroyCluster
    end
  end

  class Group
    def self.create(res_grp)
      objWMIService = Mscs::Cluster.wmiconnect
      objClus = objWMIService.Get("MSCluster_ResourceGroup")
      oMethod=objClus.Methods_("CreateGroup")
      oInParam = oMethod.InParameters.SpawnInstance_()
      oInParam.GroupName = res_grp
      oOutParam = objClus.ExecMethod_("CreateGroup", oInParam)
    end

    def self.delete(res_grp)
      objWMIService = Mscs::Cluster.wmiconnect
      groups=objWMIService.ExecQuery("select name from MSCluster_ResourceGroup where Name='#{res_grp}'")
      groups.each {|group| group.DeleteGroup}
    end

    def self.query
      grouplist = []
      objWMIService = Mscs::Cluster.wmiconnect
      groups=objWMIService.ExecQuery('select name from MScluster_ResourceGroup')
      groups.each {|group| grouplist << group.name}
      return grouplist
    end
  end

  class Resource
    def self.add(res_name, res_type, res_grp)
      res_type = 'IP Address' if res_type =~ /ip/i
      res_type = 'Network Name' if ['nn', 'networkname'].include?(res_type.downcase)

      objWMIService = Mscs::Cluster.wmiconnect
      objClus = objWMIService.Get("MSCluster_Resource")
      oMethod=objClus.Methods_("CreateResource")
      oInParam = oMethod.InParameters.SpawnInstance_()
      oInParam.ResourceName = res_name
      oInParam.Resourcetype = res_type
      oInParam.Group = res_grp
      oOutParam = objClus.ExecMethod_("CreateResource", oInParam)
    end

    def self.delete(res_name)
      objWMIService = Mscs::Cluster.wmiconnect
      resources=objWMIService.ExecQuery("select * from MSCluster_Resource where Name='#{res_name}'")
      resources.each {|resource| resource.DeleteResource}
    end

    def self.getgroup(res_name)
      objWMIService = Mscs::Cluster.wmiconnect
      wql = "ASSOCIATORS OF {MSCluster_Resource.Name='#{res_name}'} WHERE AssocClass = MSCluster_ResourceGroupToResource"
      group=objWMIService.ExecQuery(wql)
      group.each.first.name
    end

    def self.query
      resourcelist = []
      objWMIService = Mscs::Cluster.wmiconnect
      resources=objWMIService.ExecQuery('select name from MScluster_Resource')
      resources.each {|resource| resourcelist << resource.name}
      return resourcelist
    end

    def self.set_priv (resource,hash_res={})

      objWMIService = Mscs::Cluster.wmiconnect
      colItems = objWMIService.ExecQuery("Select * from MSCluster_Resource where name='#{resource}'")
      colItems.each {|property|
        @property=property
        @res_type=@property.properties_('Type').value
      }

      case @res_type
      when "IP Address"
        hash_res.has_key?(:enabledhcp) or raise 'enabledhcp needs 0 or 1 (static 0 or dhcp 1)'
        hash_res.has_key?(:address) or raise 'ipaddr needed'
        hash_res.has_key?(:subnetmask) or raise 'subnetmask needed'
        hash_res.has_key?(:network) or raise 'network needed'
        hash_res.has_key?(:enablenetbios) or raise 'enablenetbios needed'
        @property.PrivateProperties.Properties_.item(:enabledhcp.to_s).value = hash_res[:enabledhcp]

      when "Network Name"
        hash_res.has_key?(:name) or raise 'network name must have name'
      when "File Server"
        hash_res.has_key?(:name) or raise 'name needed'
        hash_res.has_key?(:path) or raise 'path needed'
        hash_res.has_key?(:sharename) or raise 'sharename needed'
        hash_res.has_key?(:remark) or raise 'remark needed'
        hash_res.has_key?(:sharesubdirs) or raise 'sharesubdirs needed'
      when "Generic Service"
        hash_res.has_key?(:servicename) or raise 'serviceName needed'
        hash_res.has_key?(:startupparameters) or raise 'startupParameters needed'
        hash_res.has_key?(:sharename) or raise 'shareName needed'
      when "Physical Disk"
        hash_res.has_key?(:signature) or raise 'signature needed'
        hash_res.has_key?(:skipchkdsk) or raise 'skipchkdsk needed'
        hash_res.has_key?(:conditionalmount) or raise 'conditionalmount needed'
      when "Generic Application"
        hash_res.has_key?(:commandline) or raise 'commandline needed'
        hash_res.has_key?(:currentdirectory) or raise 'currentdirectory needed'
        hash_res.has_key?(:interactwithdesktop) or raise 'interactwithdesktop needed'
        hash_res.has_key?(:usenetworkname) or raise 'usenetworkname needed'
      end #case

      hash_res.each do |key, value| key!= :enabledhcp
        key=key.to_s
        @property.PrivateProperties.Properties_.item(key).value = value
      end

      @property.Put_()
      @property = nil
    end

    def self.query_priv (resource)
      objWMIService = Mscs::Cluster.wmiconnect
      colItems = objWMIService.ExecQuery("Select * from MSCluster_Resource where name='#{resource}'")
      colItems.each {|property|
        @property=property
        @res_type=@property.properties_('Type').value
      }
      keylist, values = []
      @property.PrivateProperties.Properties_.each {|keys| keylist << keys.name}
      keylist.each {|key| values << @property.PrivateProperties.Properties_.item(key).value}
      priv_props = Hash[a.zip b]
    end

    class Dependency
      def self.add(res_name, dependson)
        objWMIService = Mscs::Cluster.wmiconnect
        resources=objWMIService.ExecQuery("select * from MSCluster_ResourceGroup where Name='#{res_name}'")
        resources.each.first.AddDependency(dependson)
      end

      def self.remove(res_name, dependson)
        objWMIService = Mscs::Cluster.wmiconnect
        resources=objWMIService.ExecQuery("select * from MSCluster_ResourceGroup where Name='#{res_name}'")
        resources.each.first.RemoveDependency(dependson)
      end
    end
  end


  class Disk
    def self.add(diskid)
      objWMIService = Mscs::Cluster.wmiconnect
      objAvailableDisks = objWMIService.ExecQuery("Select * from MSCluster_AvailableDisk where ID='#{diskid}'")
      objAvailableDisks.each do |disk|
        disk.AddToCluster
      end
    end

    def self.remove(diskid)
      objWMIService = Mscs::Cluster.wmiconnect
      disks=objWMIService.ExecQuery("select * from mscluster_resource where PrivateProperties.DiskSignature='#{diskid}'")
      disks.each {|disk| disk.DeleteResource}
    end

    def self.query
      disklist = []
      objWMIService = Mscs::Cluster.wmiconnect
      objAddedDisks = objWMIService.ExecQuery("Select ID from MSCluster_Disk")
      objAddedDisks.each {|disk| disklist << disk.ID}
      return disklist
    end

    def self.move(diskid,res_grp)
      objWMIService = Mscs::Cluster.wmiconnect
      disks=objWMIService.ExecQuery("select * from mscluster_resource where PrivateProperties.DiskSignature='#{diskid}'")
      disks.each {|disk| disk.MoveToNewGroup(res_grp)}
    end

    def self.rename(diskid,newname)
      objWMIService = Mscs::Cluster.wmiconnect
      disks=objWMIService.ExecQuery("select * from mscluster_resource where PrivateProperties.DiskSignature='#{diskid}'")
      disks.each {|disk| disk.Rename(newname)}
    end

  end

  class Node
    def self.add(node)
      objWMIService = Mscs::Cluster.wmiconnect
      objClus = objWMIService.Get("MSCluster_Cluster")
      oMethod=objClus.Methods_("AddNode")
      oInParam = oMethod.InParameters.SpawnInstance_()
      oInParam.NodeName = node
      oOutParam = objClus.ExecMethod_("AddNode", oInParam)
    end

    def self.remove(node)
      objWMIService = Mscs::Cluster.wmiconnect
      objClus = objWMIService.Get("MSCluster_Cluster")
      oMethod=objClus.Methods_("EvictNode")
      oInParam = oMethod.InParameters.SpawnInstance_()
      oInParam.NodeName = node
      oOutParam = objClus.ExecMethod_("EvictNode", oInParam)
    end

    def self.query
      nodelist = []
      objWMIService = Mscs::Cluster.wmiconnect
      nodes=objWMIService.ExecQuery('select systemname from mscluster_service')
      nodes.each {|node| nodelist << node.systemname}
      return nodelist
    end
  end
end