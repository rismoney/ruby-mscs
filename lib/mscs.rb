def utf8_to_utf16le(my_str)
  my_str = my_str + "\000\000" #double null termination - wtf
  my_str = begin
    if my_str.respond_to?(:encode)
      my_str.encode('UTF-16LE')
    else
      require 'iconv'
      Iconv.conv("UTF-16LE", "UTF-8", my_str)
    end
  end
  my_str
end

def utf16le_to_usascii(my_str)
  
  my_str = begin
    if my_str.respond_to?(:encode)
      my_str.encode('UTF-8')
    else
      require 'iconv'
      Iconv.conv("US-ASCII", "UTF-16LE", my_str)
    end
  end
  my_str.strip!
  my_str
end

#cluster enumeration constants (bitmask)
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa368834(v=vs.85).aspx
CLUSTER_ENUM_NODE=1
CLUSTER_ENUM_RESTYPE=2
CLUSTER_ENUM_RESOURCE=4
CLUSTER_ENUM_GROUP=8
CLUSTER_ENUM_NETWORK=16
CLUSTER_ENUM_NETINTERFACE=32
CLUSTER_ENUM_SHARED_VOLUME_RESOURCE=1073741824 
CLUSTER_ENUM_INTERNAL_NETWORK=2147483648 

#clustergroup enumeration constants
# http://msdn.microsoft.com/en-us/library/windows/desktop/bb309149(v=vs.85).aspx
CLUSTER_GROUP_ENUM_CONTAINS=1
CLUSTER_GROUP_ENUM_NODES=2
CLUSTER_GROUP_ENUM_ALL=3

#cluster resource enumeration constants
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa369028(v=vs.85).aspx

CLUSTER_RESOURCE_ENUM_DEPENDS=1
CLUSTER_RESOURCE_ENUM_PROVIDES=2
CLUSTER_RESOURCE_ENUM_NODES=4

# http://msdn.microsoft.com/en-us/library/windows/desktop/cc307921(v=vs.85).aspx
# cluster control codes
CLUSCTL_RESOURCE_UNKNOWN                           = 0x01000000
CLUSCTL_RESOURCE_GET_CHARACTERISTICS               = 0x01000005
CLUSCTL_RESOURCE_GET_FLAGS                         = 0x01000009
CLUSCTL_RESOURCE_GET_CLASS_INFO                    = 0x0100000d
CLUSCTL_RESOURCE_GET_REQUIRED_DEPENDENCIES         = 0x01000011
CLUSCTL_RESOURCE_GET_NAME                          = 0x01000029
CLUSCTL_RESOURCE_GET_ID                            = 0x01000039
CLUSCTL_RESOURCE_GET_RESOURCE_TYPE                 = 0x0100002d
CLUSCTL_RESOURCE_ENUM_COMMON_PROPERTIES            = 0x01000051
CLUSCTL_RESOURCE_GET_RO_COMMON_PROPERTIES          = 0x01000055
CLUSCTL_RESOURCE_GET_COMMON_PROPERTIES             = 0x01000059
CLUSCTL_RESOURCE_SET_COMMON_PROPERTIES             = 0x0140005e
CLUSCTL_RESOURCE_VALIDATE_COMMON_PROPERTIES        = 0x01000061
CLUSCTL_RESOURCE_GET_COMMON_PROPERTY_FMTS          = 0x01000065
CLUSCTL_RESOURCE_ENUM_PRIVATE_PROPERTIES           = 0x01000079
CLUSCTL_RESOURCE_GET_RO_PRIVATE_PROPERTIES         = 0x0100007d
CLUSCTL_RESOURCE_GET_PRIVATE_PROPERTIES            = 0x01000081
CLUSCTL_RESOURCE_SET_PRIVATE_PROPERTIES            = 0x01400086
CLUSCTL_RESOURCE_VALIDATE_PRIVATE_PROPERTIES       = 0x01000089
CLUSCTL_RESOURCE_GET_PRIVATE_PROPERTY_FMTS         = 0x0100008d
CLUSCTL_RESOURCE_ADD_REGISTRY_CHECKPOINT           = 0x014000a2
CLUSCTL_RESOURCE_DELETE_REGISTRY_CHECKPOINT        = 0x014000a6
CLUSCTL_RESOURCE_GET_REGISTRY_CHECKPOINTS          = 0x010000a9
CLUSCTL_RESOURCE_ADD_CRYPTO_CHECKPOINT             = 0x014000ae
CLUSCTL_RESOURCE_DELETE_CRYPTO_CHECKPOINT          = 0x014000b2
CLUSCTL_RESOURCE_GET_CRYPTO_CHECKPOINTS            = 0x010000b5
CLUSCTL_RESOURCE_GET_LOADBAL_PROCESS_LIST          = 0x010000c9
CLUSCTL_RESOURCE_GET_NETWORK_NAME                  = 0x01000169
CLUSCTL_RESOURCE_NETNAME_GET_VIRTUAL_SERVER_TOKEN  = 0x0100016d
CLUSCTL_RESOURCE_NETNAME_SET_PWD_INFO              = 0x0100017a
CLUSCTL_RESOURCE_NETNAME_DELETE_CO                 = 0x0100017e
CLUSCTL_RESOURCE_NETNAME_VALIDATE_VCO              = 0x01000181
CLUSCTL_RESOURCE_NETNAME_RESET_VCO                 = 0x01000185
CLUSCTL_RESOURCE_NETNAME_REGISTER_DNS_RECORDS      = 0x01000172
CLUSCTL_RESOURCE_GET_DNS_NAME                      = 0x01000175
CLUSCTL_RESOURCE_STORAGE_GET_DISK_INFO             = 0x01000191
CLUSCTL_RESOURCE_STORAGE_IS_PATH_VALID             = 0x01000199
CLUSCTL_RESOURCE_QUERY_DELETE                      = 0x010001b9
CLUSCTL_RESOURCE_UPGRADE_DLL                       = 0x014000ba
CLUSCTL_RESOURCE_IPADDRESS_RENEW_LEASE             = 0x014001be
CLUSCTL_RESOURCE_IPADDRESS_RELEASE_LEASE           = 0x014001c2
CLUSCTL_RESOURCE_ADD_REGISTRY_CHECKPOINT_64BIT     = 0x014000be
CLUSCTL_RESOURCE_ADD_REGISTRY_CHECKPOINT_32BIT     = 0x014000c2
CLUSCTL_RESOURCE_QUERY_MAINTENANCE_MODE            = 0x010001e1
CLUSCTL_RESOURCE_SET_MAINTENANCE_MODE              = 0x014001e6
CLUSCTL_RESOURCE_STORAGE_SET_DRIVELETTER           = 0x014001ea
CLUSCTL_RESOURCE_STORAGE_GET_DISK_INFO_EX          = 0x010001f1
CLUSCTL_RESOURCE_FILESERVER_SHARE_ADD              = 0x01400245
CLUSCTL_RESOURCE_FILESERVER_SHARE_DEL              = 0x01400249
CLUSCTL_RESOURCE_FILESERVER_SHARE_MODIFY           = 0x0140024d
CLUSCTL_RESOURCE_FILESERVER_SHARE_REPORT           = 0x01000251
CLUSCTL_RESOURCE_STORAGE_GET_MOUNTPOINTS           = 0x01000211
CLUSCTL_RESOURCE_STORAGE_CLUSTER_DISK              = 0x01c00212
CLUSCTL_RESOURCE_STORAGE_GET_DIRTY                 = 0x01000219
CLUSCTL_RESOURCE_STORAGE_GET_SHARED_VOLUME_INFO,CLUSCTL_RESOURCE_SET_CSV_MAINTENANCE_MODE = 0x00400296,
CLUSCTL_RESOURCE_ENABLE_SHARED_VOLUME_DIRECTIO     = 0x0140028a
CLUSCTL_RESOURCE_DISABLE_SHARED_VOLUME_DIRECTIO    = 0x0140028e
CLUSCTL_RESOURCE_SET_SHARED_VOLUME_BACKUP_MODE     = 0x0140029a
CLUSCTL_RESOURCE_DELETE                            = 0x01500006
CLUSCTL_RESOURCE_INSTALL_NODE                      = 0x0150000a
CLUSCTL_RESOURCE_EVICT_NODE                        = 0x0150000e
CLUSCTL_RESOURCE_ADD_DEPENDENCY                    = 0x01500012
CLUSCTL_RESOURCE_REMOVE_DEPENDENCY                 = 0x01500016
CLUSCTL_RESOURCE_ADD_OWNER                         = 0x0150001a
CLUSCTL_RESOURCE_REMOVE_OWNER                      = 0x0150001e
CLUSCTL_RESOURCE_SET_NAME                          = 0x01500026
CLUSCTL_RESOURCE_CLUSTER_NAME_CHANGED              = 0x0150002a
CLUSCTL_RESOURCE_CLUSTER_VERSION_CHANGED           = 0x0150002e
CLUSCTL_RESOURCE_FORCE_QUORUM                      = 0x01500046
CLUSCTL_RESOURCE_INITIALIZE                        = 0x0150004a
CLUSCTL_RESOURCE_STATE_CHANGE_REASON               = 0x0150004e
CLUSCTL_RESOURCE_PROVIDER_STATE_CHANGE             = 0x01500052
CLUSCTL_RESOURCE_LEAVING_GROUP                     = 0x01500056
CLUSCTL_RESOURCE_JOINING_GROUP                     = 0x0150005a
CLUSCTL_RESOURCE_FSWITNESS_GET_EPOCH_INFO          = 0x0110005d
CLUSCTL_RESOURCE_FSWITNESS_SET_EPOCH_INFO          = 0x01500062
CLUSCTL_RESOURCE_FSWITNESS_RELEASE_LOCK            = 0x01500066
CLUSCTL_RESOURCE_NETNAME_CREDS_UPDATED             = 0x01c0018a

require "Win32API"

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

def cluster_res_ip_props (res_name, res_grp, ip_addr, ip_subnetmask, ip_network, ip_netbios='1')
  puts "#{res_name}"
  puts "#{res_grp}"
  puts "#{ip_addr}"
  puts "#{ip_subnetmask}"
  puts "#{ip_network}"
  puts "#{ip_netbios}"

  $hCluster.resourcegroups.item(res_grp).resources.item(res_name).privateproperties.item('Network').Value = ip_network
  $hCluster.resourcegroups.item(res_grp).resources.item(res_name).privateproperties.item('Address').Value = ip_addr
  $hCluster.resourcegroups.item(res_grp).resources.item(res_name).privateproperties.item('SubnetMask').Value = ip_subnetmask
  $hCluster.resourcegroups.item(res_grp).resources.item(res_name).privateproperties.item('EnableNetBIOS').Value = ip_netbios
  #$hCluster.resourcegroups.item(res_grp).resources.item(res_name).PrivateProperties.SaveChanges
  

  
end

def cluster_res_name_props (res_name, name_RemapPipeNames)
  $hCluster.Resources.item(res_name).PrivateProperties.item('Name').Value = res_name
  $hCluster.Resources.item(res_name).PrivateProperties.item('RemapPipeNames').Value = RemapPipeNames
  $hCluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_fileshare_props (res_name, fs_path, fs_sharename, fs_remark, fs_sharesubdir)
  $hCluster.Resources.item(res_name).PrivateProperties.item('Name').Value = res_name
  $hCluster.Resources.item(res_name).PrivateProperties.item('Path').Value = fs_path
  $hCluster.Resources.item(res_name).PrivateProperties.item('ShareName').Value = fs_sharename
  $hCluster.Resources.item(res_name).PrivateProperties.item('Remark').Value = fs_remark
  $hCluster.Resources.item(res_name).PrivateProperties.item('ShareSubDirs').Value = fs_sharesubdir
  $hCluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_gensvc_props (res_name, gs_servicename, gs_startupparams, gs_usenetworkname)
  $hCluster.Resources.item(res_name).PrivateProperties.item('ServiceName').Value = gs_servicename
  $hCluster.Resources.item(res_name).PrivateProperties.item('StartupParameters').Value = gs_startupparams
  $hCluster.Resources.item(res_name).PrivateProperties.item('ShareName').Value = gs_usenetworkname
  $hCluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_pdisk_props (res_name, pd_signature, pd_skipchkdsk, pd_cdtlmount)
  $hCluster.Resources.item(res_name).PrivateProperties.item('Signature').Value = pd_signature
  $hCluster.Resources.item(res_name).PrivateProperties.item('SkipChkdsk').Value = pd_skipchkdsk
  $hCluster.Resources.item(res_name).PrivateProperties.item('ConditionalMount').Value = pd_cdtlmount
  $hCluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_genapp_props (res_name, ga_commandline, ga_currentdir, ga_interactive, ga_usenetworkname)
  $hCluster.Resources.item(res_name).PrivateProperties.item('CommandLine').Value = ga_commandline
  $hCluster.Resources.item(res_name).PrivateProperties.item('CurrentDirectory').Value = ga_currentdir
  $hCluster.Resources.item(res_name).PrivateProperties.item('InteractWithDesktop').Value = ga_interactive
  $hCluster.Resources.item(res_name).PrivateProperties.item('UseNetworkName').Value = ga_usenetworkname
  $hCluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_mod_dependency (action, res_name, dependencyname)
  resource = $hCluster.Resources.item(res_name)
  dependency = $hCluster.Resources.item(dependencyname)

