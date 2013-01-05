require "Win32API"
require "win32ole"
require "./mscs_utils"
require "./mscs_const"


#opens
OpenCluster = Win32API.new('clusapi','OpenCluster',['P'], 'L')
OpenClusterGroup = Win32API.new('clusapi','OpenClusterGroup',['L','P'], 'L')
OpenClusterResource = Win32API.new('clusapi','OpenClusterResource',['L','P'], 'L')

#closes
CloseClusterResource = Win32API.new('clusapi','CloseClusterResource',['L'], 'L')
CloseClusterGroup = Win32API.new('clusapi','CloseClusterGroup',['L'], 'L')
CloseCluster = Win32API.new('clusapi','CloseCluster',['L'], 'L')

#enums
ClusterOpenEnum = Win32API.new('clusapi','ClusterOpenEnum',['L','L'], 'L')
ClusterEnum = Win32API.new('clusapi','ClusterEnum',['L','L','P','P','P'], 'L')
ClusterGroupOpenEnum = Win32API.new('clusapi','ClusterGroupOpenEnum',['L','L'], 'L')
ClusterGroupEnum = Win32API.new('clusapi','ClusterGroupEnum',['L','L','P','P','P'], 'L')
ClusterResourceOpenEnum = Win32API.new('clusapi','ClusterResourceOpenEnum',['L','L'], 'L')
ClusterResourceEnum = Win32API.new('clusapi','ClusterResourceEnum',['L','L','P','P','P'], 'L')

#create-delete
CreateClusterGroup = Win32API.new('clusapi','CreateClusterGroup',['L','P'], 'L')
DeleteClusterGroup = Win32API.new('clusapi','DeleteClusterGroup',['L'], 'L')
CreateClusterResource = Win32API.new('clusapi','CreateClusterResource',['L','P','P','L'], 'L')
DeleteClusterResource = Win32API.new('clusapi','DeleteClusterResource',['L'], 'L')

#state
OnlineClusterGroup = Win32API.new('clusapi','OnlineClusterGroup',['L','L'], 'L')
OfflineClusterGroup = Win32API.new('clusapi','OfflineClusterGroup',['L'], 'L')

#resource control
ClusterResourceControl = Win32API.new('clusapi','ClusterResourceControl',['L','L','L','P','L','P','L','P'], 'L')

#i didn't even know about these! was gonna parse this nonsense myself :)
ResUtilFindSzProperty = Win32API.new('resutils','ResUtilFindSzProperty',['P','L','P','P'], 'L')

# dependency mgmt
AddClusterResourceDependency = Win32API.new('clusapi','AddClusterResourceDependency',['P','P'], 'L')
CanResourceBeDependent = Win32API.new('clusapi','CanResourceBeDependent',['P','P'], 'L')
RemoveClusterResourceDependency = Win32API.new('clusapi','RemoveClusterResourceDependency',['P','P'], 'L')

def clus_open(open_type, open_name, cluster_handle=nil)
  open_name = utf8_to_utf16le(open_name)
 
  cluster_open = begin
    case open_type
    when 'Cluster'      ; OpenCluster
    when 'Group'        ; OpenClusterGroup
    when 'Resource'     ; OpenClusterResource
    # when 'NetInterface' ; OpenClusterNetInterface
    # when 'Network'      ; OpenClusterNetWork
    # when 'Node'         ; OpenClusterNode
    end
  end
 
  # only 1 arg needed for OpenCluster, 2 for the others
  
  
  open_type == 'Cluster' ? (handle = cluster_open.call(open_name)) : (handle = cluster_open.call(cluster_handle,open_name))
  return handle
  
end

def clus_enumeration(enumerationtype, myhandle, dwtype)
  chrs = (0.chr * 260)
  buffer1=utf8_to_utf16le(chrs)
  buffer2=utf8_to_utf16le(chrs)
  size=utf8_to_utf16le('260')
  outputlist = []
  handle = myhandle

  cluster_open_enum, cluster_enum = begin
    case enumerationtype
    when 'Cluster'  ; [ClusterOpenEnum, ClusterEnum]
    when 'Group'    ; [ClusterGroupOpenEnum, ClusterGroupEnum]
    when 'Resource' ; [ClusterResourceOpenEnum, ClusterResourceEnum]
    end
  end
  
  hEnum = cluster_open_enum.call(handle, dwtype)

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


def clus_group(action, hCluster, res_grp)

  case action
    when "add"
      res_grp = utf8_to_utf16le(res_grp)
      CreateClusterGroup.call(hCluster,res_grp)
    when "remove"
      
      hGroup=clus_open('Group', res_grp, hCluster)
      DeleteClusterGroup.call(hGroup)    # this needs to be the handle of the group not the name. enum groups...
    when "query"
      

      hGroup=clus_open('Group', res_grp, hCluster)
      
      clus_enumeration('Group',hGroup, CLUSTER_GROUP_ENUM_CONTAINS)
  end  
end
  
def clus_res(action, hCluster, res_name, res_type, res_grp)

  case action
    when "add"
      res_type = 'IP Address' if res_type =~ /ip/i
      res_type = 'Network Name' if ['nn', 'networkname'].include?(res_type.downcase)
      
      res_name = utf8_to_utf16le(res_name)
      res_type = utf8_to_utf16le(res_type)
 
      hGroup=clus_open('Group', res_grp, hCluster)
      hRes = CreateClusterResource.call(hGroup,res_name,res_type,0)
    when "remove"
      hResource=clus_open('Resource', res_name, hCluster)
      DeleteClusterResource.call(hResource)
    when "query"
    
      hResource=clus_open('Resource', res_name, hCluster)
      
      # if hResource is a Fix >0 then run this, otherwise irb shits the bed.  we should probably fix all the other calls after opens
      clus_enumeration('Resource', hResource, CLUSTER_RESOURCE_ENUM_DEPENDS)
    end
end


def cluster_res_props (cluster,resource,hash_res={})

  # this is currently using OLE for ease of use - it will be deprecated after Win2012
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
  end
  puts hash_res
  
  hash_res.each do |key, value| key!= :enabledhcp
    key=key.to_s
    hcluster.Resources.item(resource).PrivateProperties.item(key).Value = value
  end
  
  hcluster.Resources.item(resource).PrivateProperties.savechanges
  hcluster = nil

end  
  
  
def cluster_mod_dependency (action, hCluster, res_name, dependendson)
  hres_name=clus_open('Resource', res_name, hCluster)
  hdependendson=clus_open('Resource', res_name, hCluster)
  case action
    when "add"
    
      if CanResourceBeDependent(hres_name, hdependendson)
        AddClusterResourceDependency(hres_name, hdependendson)
      else
        raise_error #not sure what I want to do here yet
      end
    when "remove"
      #need if it is already dependendent) check
      RemoveClusterResourceDependency(hres_name, hdependendson)
  end
end
