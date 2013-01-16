require 'pathname'
dir = Pathname.new(__FILE__).parent
$LOAD_PATH.unshift(dir, dir + 'lib', dir + '../lib')


module Mscs

  Dir[File.join(File.dirname(__FILE__), 'mscs', '*.rb')].each do |mscs_file|
    require mscs_file
  end

  include Mscs::Constants
  extend Mscs::Functions
  extend Mscs::Constants

  class Cluster

    def self.wmiconnect(clustername,kerb_name=nil)
      if kerb_name
        objWMIService  = WIN32OLE.connect("winmgmts:{impersonationLevel=delegate,authenticationLevel=pktPrivacy,authority=kerberos:#{kerb_name}}!\\\\#{clustername}\\root\\mscluster")
      else
        objWMIService  = WIN32OLE.connect("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy}!\\\\#{clustername}\\root\\mscluster")
      end
      return objWMIService
    end

    def self.open(open_type, open_name, cluster_handle=nil)
      open_name = utf8_to_utf16le(open_name)
     
      cluster_open = begin
        case open_type
        when 'Cluster'      ; Functions::OpenCluster
        when 'Group'        ; Functions::OpenClusterGroup
        when 'Resource'     ; Functions::OpenClusterResource
        when 'Network'      ; Functions::OpenClusterNetWork
        when 'Node'         ; Functions::OpenClusterNode
        end
      end

      # only 1 arg needed for OpenCluster, 2 for the others

      open_type == 'Cluster' ? (handle = cluster_open.call(open_name)) : (handle = cluster_open.call(cluster_handle,open_name))
      return handle
    end

    def self.enumerate(enumerationtype, myhandle, dwtype)
      chrs = (0.chr * 260)
      buffer1=utf8_to_utf16le(chrs)
      buffer2=utf8_to_utf16le(chrs)
      size=utf8_to_utf16le('260')
      outputlist = []
      handle = myhandle

      open_enum, cluster_enum = begin
        case enumerationtype
        when 'Cluster'  ; [Functions::ClusterOpenEnum, Functions::ClusterEnum]
        when 'Group'    ; [Functions::ClusterGroupOpenEnum, Functions::ClusterGroupEnum]
        when 'Resource' ; [Functions::ClusterResourceOpenEnum, Functions::ClusterResourceEnum]
        when 'Network' ;  [Functions::ClusterNetworkOpenEnum, Functions::ClusterNetworkEnum]
        when 'Node' ;     [Functions::ClusterNodeOpenEnum, Functions::ClusterNodeEnum]
        end
      end

      hEnum = open_enum.call(handle, dwtype)

      i = 0
      until cluster_enum.call(hEnum, i, buffer1, buffer2, size) !=0
        bufferlength, = size.unpack('L')
        outputname = utf16le_to_usascii(buffer2).slice(0..bufferlength).strip
        outputlist << outputname
        size=utf8_to_utf16le('260')
        i += 1
      end

      return outputlist
    end

    def self.name(hCluster)
      chrs = (0.chr * 260)
      buffer1=utf8_to_utf16le(chrs)
      size=utf8_to_utf16le('260')
      Functions::GetClusterInformation.call(hCluster,buffer1,size,0)
      name=(utf16le_to_usascii(buffer1)).strip
      return name
    end

    def self.create(server, cluster_config={},wmi_username=nil)
      cluster_config.has_key?(:ClusterName) or raise 'requires ClusterName key'
      cluster_config.has_key?(:IPAddresses) or raise 'requires IPAddresses key'
      cluster_config.has_key?(:NodeNames) or raise 'requires NodeNames key'
      cluster_config.has_key?(:SubnetMasks) or raise 'requires SubnetMasks key'
      
      wmi_username ? (objWMIService=Mscs::Cluster.wmiconnect(server,wmi_username)) : (objWMIService=Mscs::Cluster.wmiconnect server)
      objClus = objWMIService.Get("MSCluster_cluster")
      objInParam= objClus.Methods_("CreateCluster").InParameters.SpawnInstance_()
      cluster_config.each do |key, value|
        key=key.to_s
        objInParam.Properties_.item(key).value = value
      end

      objoutparams = objClus.ExecMethod_("CreateCluster", objInParam)
    end


    def self.createapi_busted
      #cluster_name, nodes, ips
      
      cluster_name = 'cc-git.office.iseoptions.com'
      nodes = ['cc-git01']
      ips = ['30.3.4.45']
      version = 0x700
      cluster_name = utf8_to_utf16le(cluster_name)

      cluster_config = Struct.new(:version, :clustername, :nodecount, :nodes, :ipcount, :ips, :emptycluster)
      node_array_ptr=[]

      nodes.each {|item| node_array_ptr << utf8_to_utf16le(item)}
      nodes_ptr = node_array_ptr.map{|x| [x].pack('p')}.join
      nodelist = [nodes_ptr].pack('p').unpack('L').first
      cnodes = 1

      ip_entry = Struct.new(:ip,:len)
      ipentry_array=[]
      ips.each {|item| ipentry_array.push(ip_entry.new utf8_to_utf16le(item),24)}
      ipentry_array_ptr = ipentry_array.map{|x| x.to_a.pack('pL')}
      ipentry_ptr = ipentry_array_ptr.map{|x| [x].pack('p')}.join
      iplist = [ipentry_ptr].pack('p').unpack('L').first

      cips = ipentry_array.count
      cluster_config_struct = cluster_config.new(version, cluster_name, cnodes, nodelist, cips, iplist, 0)
      cluster_config_ptr = cluster_config_struct.to_a.pack("LpLLLLL")
      address = [cluster_config_ptr].pack('p').unpack('L').first

      getlasterror = Win32API.new("Kernel32","GetLastError", "V", "N")

      Functions::CreateCluster.call(address,nil,nil)
      puts "GetLastError = #{getlasterror.Call}"
    end
  
    def self.destroy(hCluster)
      Functions::DestroyCluster.call(hCluster,nil,nil, 1)
    end 

  end
  
  class Group
    def self.add(hCluster, res_grp)
      res_grp = utf8_to_utf16le(res_grp)
      Functions::CreateClusterGroup.call(hCluster,res_grp)
    end

    def self.remove(hCluster, res_grp)
      hGroup=Mscs::Cluster.open('Group', res_grp, hCluster)
      Functions::DeleteClusterGroup.call(hGroup)    # this needs to be the handle of the group not the name. enum groups...
    end

    def self.query(hCluster, res_grp)
      hGroup=Mscs::Cluster.open('Group', res_grp, hCluster)
      Mscs::Cluster.enumerate('Group',hGroup, Constants::CLUSTER_GROUP_ENUM_CONTAINS)
    end  
  end
  
  class Resource
    def self.add(hCluster, res_name, res_type, res_grp)
      res_type = 'IP Address' if res_type =~ /ip/i
      res_type = 'Network Name' if ['nn', 'networkname'].include?(res_type.downcase)
      res_name = utf8_to_utf16le(res_name)
      res_type = utf8_to_utf16le(res_type)
      hGroup=Mscs::Cluster.open('Group', res_grp, hCluster)
      hRes = Functions::CreateClusterResource.call(hGroup,res_name,res_type,0)
    end

    def self.remove(hCluster, res_name)
      hResource=Mscs::Cluster.open('Resource', res_name, hCluster)
      Functions::DeleteClusterResource.call(hResource)
    end

    def self.query(hCluster, res_name)
      hResource = Mscs::Cluster.open('Resource', res_name, hCluster)
      # if hResource is a Fix >0 then run this, otherwise irb shits the bed.  we should probably fix all the other calls after opens
      Mscs::Cluster.enumerate('Resource', hResource, Constants::CLUSTER_RESOURCE_ENUM_DEPENDS)
    end

    def self.set_priv (hCluster,resource,hash_res={})

      clustername=Mscs::Cluster.name(hCluster)
      objWMIService=Mscs::Cluster.wmiconnect clustername
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

    def self.query_priv (hCluster,resource,priv_array)
      res_privprop= {}
      size="0" * 260
      chrs = (0.chr * 1024)
      buffer1=utf8_to_utf16le(chrs)
      buffer2=utf8_to_utf16le(chrs)
      hResource=Mscs::Cluster.open('Resource', resource, hCluster)
      Functions::ClusterResourceControl.call(hResource, 0, Constants::CLUSCTL_RESOURCE_GET_PRIVATE_PROPERTIES, 0, 0, buffer1, 4096, size)
      size = size.unpack('L')

      priv_array.each { |item| 
        ptr = 0.chr * 4
        res=Functions::ResUtilFindSzProperty.call(buffer1, size[0], utf8_to_utf16le(item), ptr)
        lstrcpyW = Win32API.new('kernel32','lstrcpyW',['P','L'],'P')
        lstrcpyW.call(buffer2, ptr.unpack('L')[0])
        value = (utf16le_to_usascii(buffer2)).strip
        attrib = item.to_sym
        res_privprop[attrib] = value
        buffer2=utf8_to_utf16le(chrs)
      }
      return res_privprop
    end

    class Dependency
      def self.add(hCluster, res_name, dependson)
        hres_name=Mscs::Cluster.open('Resource', res_name, hCluster)
        hdependson=Mscs::Cluster.open('Resource', dependson, hCluster)

        if Functions::CanResourceBeDependent.call(hres_name, hdependson)
          Functions::AddClusterResourceDependency.call(hres_name, hdependson)
        else
          raise_error #not sure what I want to do here yet
        end #if
      end #add

      def self.remove(hCluster, res_name, dependson)
          hres_name=Mscs::Cluster.open('Resource', res_name, hCluster)
          hdependson=Mscs::Cluster.open('Resource', dependson, hCluster)

          #need if it is already dependendent) check
          Functions::RemoveClusterResourceDependency.call(hres_name, hdependson)
      end #remove
    end #dependency
  end
  
  class Node
    def self.add(hCluster, node)
      node = utf8_to_utf16le(node)
      Functions::CreateClusterNode.call(hCluster,node)
    end

    def self.remove(hCluster, node)
      hGroup=Mscs::Cluster.open('Node', node, hCluster)
      Functions::DeleteClusterNode.call(hGroup)    # this needs to be the handle of the group not the name. enum groups...
    end

    def self.query(hCluster, node)
      Mscs::Cluster.enumerate('Cluster',hcluster,CLUSTER_ENUM_NODE)
    end  
  end

  class Network
    def self.SetClusterNetworkName(hCluster,new)
      network
    end
  end
end