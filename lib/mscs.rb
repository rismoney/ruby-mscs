require "Win32API"
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

    def self.set_priv (action,cluster,resource,hash_res={})

    # add is currently using OLE for ease of use - it will be deprecated after Win2012
    # this was a shortcut to using property lists via win32api/ffi
    # $cluster.ole_methods.collect!{ |e| e.to_s }.sort
    
      hcluster = WIN32OLE.new('MSCluster.Cluster')
      hcluster.open(cluster)
      case hcluster.Resources.item(resource).Typename
      when "IP Address"
        hash_res.has_key?(:enabledhcp) or raise 'enabledhcp needs 0 or 1 (static 0 or dhcp 1)'
        hash_res.has_key?(:address) or raise 'ipaddr needed'
        hash_res.has_key?(:subnetmask) or raise 'subnetmask needed'
        hash_res.has_key?(:network) or raise 'network needed'
        hash_res.has_key?(:enablenetbios) or raise 'enablenetbios needed'
        hcluster.Resources.item(resource).PrivateProperties.item(:enabledhcp.to_s).Value = hash_res[:enabledhcp]
      when "Network Name"
        hash_res.has_key?(:name) or raise 'network name must have name'
        hash_res.has_key?(:remappipenames) or raise 'remappipenames'
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
        hcluster.Resources.item(resource).PrivateProperties.item(key).Value = value
      end

      hcluster.Resources.item(resource).PrivateProperties.savechanges
      hcluster = nil
    end

    def self.query_priv (hCluster,resource,hash_res={})
      output=[]
      size="0" * 260
      chrs = (0.chr * 1024)
      buffer1=utf8_to_utf16le(chrs)
      buffer2=utf8_to_utf16le(chrs)
      hResource=Mscs.open('Resource', resource, hcluster)
      ClusterResourceControl.call(hResource, 0, CLUSCTL_RESOURCE_GET_PRIVATE_PROPERTIES, 0, 0, buffer1, 4096, size)
      size = size.unpack('L')
      hash_res.each do |key, value| 
        key=key.to_s
        ptr = 0.chr * 4
        res=ResUtilFindSzProperty.call(buffer1, size[0], utf8_to_utf16le("Address"), ptr)
        lstrcpyW.call(buffer2, ptr.unpack('L')[0])
        outputname = utf16le_to_usascii(buffer1).slice(0..sizep).strip
        outputlist << outputname
      end
    end  

    def dependency_add (hCluster, res_name, dependendson)
      hres_name=Mscs.open('Resource', res_name, hCluster)
      hdependendson=Mscs.open('Resource', res_name, hCluster)

      if CanResourceBeDependent(hres_name, hdependendson)
        AddClusterResourceDependency(hres_name, hdependendson)
      else
        raise_error #not sure what I want to do here yet
      end
    end  
          
    def dependency_remove (hCluster, res_name, dependendson)
        hres_name=Mscs.open('Resource', res_name, hCluster)
        hdependendson=Mscs.open('Resource', res_name, hCluster)

        #need if it is already dependendent) check
        RemoveClusterResourceDependency(hres_name, hdependendson)

    end
  end
end
  # some notes

  # need to be able to configure :
  # network name
  # SetClusterNetworkPriorityOrd
  # setclusterquorom resource

  # state mgmt:
  # online /offline groups
  # FailClusterResource 
  # online /offline resources

  # cluster creation:
  # AddClusterNode
  # EvictClusterNode
  # destroycluster - de-prioritized

  # Close All Handles section - like open
  # 

  # set cluster group name - deprioritized
  # SetClusterGroupNodeList - nice to have

  # nice to have Remove ClusterResourceNode 