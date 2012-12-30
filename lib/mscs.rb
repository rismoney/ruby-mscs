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

#cluster enumeration constants (bitmask)
CLUSTER_ENUM_NODE=1
CLUSTER_ENUM_RESTYPE=2
CLUSTER_ENUM_RESOURCE=4
CLUSTER_ENUM_GROUP=8
CLUSTER_ENUM_NETWORK=16
CLUSTER_ENUM_NETINTERFACE=32
CLUSTER_ENUM_SHARED_VOLUME_RESOURCE=1073741824 
CLUSTER_ENUM_INTERNAL_NETWORK=2147483648 

#clustergroup enumeration constants
CLUSTER_GROUP_ENUM_CONTAINS=1
CLUSTER_GROUP_ENUM_NODES=2
CLUSTER_GROUP_ENUM_ALL=3

#cluster resource enumeration constants
CLUSTER_RESOURCE_ENUM_DEPENDS=1
CLUSTER_RESOURCE_ENUM_PROVIDES=2
CLUSTER_RESOURCE_ENUM_NODES=4

require "Win32API"
cluster_name = utf8_to_utf16le("cx-fs01")

OpenCluster = Win32API.new('clusapi','OpenCluster',['P'], 'L')
ClusterOpenEnum = Win32API.new('clusapi','ClusterOpenEnum',['L','L'], 'L')
ClusterEnum = Win32API.new('clusapi','ClusterEnum',['L','L','P','P','P'], 'L')
ClusterGroupOpenEnum = Win32API.new('clusapi','ClusterGroupOpenEnum',['L','L'], 'L')
ClusterGroupEnum = Win32API.new('clusapi','ClusterGroupEnum',['L','L','P','P','P'], 'L')
ClusterResourceOpenEnum = Win32API.new('clusapi','ClusterResourceOpenEnum',['L','L'], 'L')
ClusterResourceEnum = Win32API.new('clusapi','ClusterResourceEnum',['L','L','P','P','P'], 'L')
CreateClusterGroup = Win32API.new('clusapi','CreateClusterGroup',['L','P'], 'L')
DeleteClusterGroup = Win32API.new('clusapi','DeleteClusterGroup',['L'], 'L')
CreateClusterResource = Win32API.new('clusapi','CreateClusterResource',['L','P','P','L'], 'L')
OnlineClusterGroup = Win32API.new('clusapi','OnlineClusterGroup',['L','L'], 'L')
OfflineClusterGroup = Win32API.new('clusapi','OfflineClusterGroup',['L'], 'L')
DeleteClusterResource = Win32API.new('clusapi','DeleteClusterResource',['L'], 'L')
CloseClusterResource = Win32API.new('clusapi','CloseClusterResource',['L'], 'L')
CloseClusterGroup = Win32API.new('clusapi','CloseClusterGroup',['L'], 'L')
CloseCluster = Win32API.new('clusapi','CloseCluster',['L'], 'L')

$hCluster = OpenCluster.call(cluster_name)

def clusterenumeration(enumerationtype, myhandle, dwtype)
  enc, chrs = 'UTF-16LE', (0.chr * 260)
  buffer1  = chrs.encode(enc)
  buffer2 = chrs.encode(enc)
  size = '260'.encode(enc)
  outputlist = []
  handle = myhandle

  cluster, cluster_enum = begin
    case enumerationtype
    when 'Cluster'  ; handle = $hCluster; [ClusterOpenEnum, ClusterEnum]
    when 'Group'    ; [ClusterGroupOpenEnum, ClusterGroupEnum]
    when 'Resource' ; [ClusterResourceOpenEnum, ClusterResourceEnum]
    end
  end
  
  hEnum = cluster.call(handle, dwtype)

  i = 0
  until cluster_enum.call(hEnum, i, buffer1, buffer2, size) !=0
    bufferlength, = size.unpack('L')
    outputname = buf2.slice(0..bufferlength).encode('US-ASCII').strip
    outputlist << outputname
    size = '260'.encode(enc)
    i += 1
  end

  return outputlist
end


def cluster_group(action, groupname)
  groupname = utf8_to_utf16le(groupname)
  case action
    when "add"
      CreateClusterGroup.call($hCluster,groupname)
    when "remove"
      DeleteClusterGroup.call(groupname)    
    when "query"
      ClusterEnumeration('Group',groupname,CLUSTER_GROUP_ENUM_CONTAINS)
    end  
end
  
def cluster_res(action, res_name, res_type, res_grp)
    res_type = 'IP Address' if res_type =~ /ip/i
    res_type = 'Network Name' if ['nn', 'networkname'].include?(res_type.downcase)
   
    res_name = utf8_to_utf16le(res_name)
    res_type = utf8_to_utf16le(res_type)
    res_grp = utf8_to_utf16le(res_grp)
    
  case action
    when "add"
      hRes = CreateClusterResource.call(hGroup,res_name,res_type,0)
    when "remove"
      DeleteClusterResource.call(hRes)    
    when "query"
      ClusterEnumeration(CLUSTER_ENUM_RESOURCE,groupname,CLUSTER_RESOURCE_ENUM_DEPENDS)
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

case action
  when "add"
    if resource.CanResourceBeDependent(dependency)
      resource.Dependencies.AddItem(dependency)
    else
      raise_error #not sure what I want to do here yet
    end
  when "remove"
    #need if it is already dependendent) check
    resource.Dependencies.RemoveItem(dependency)
  end
end

#def cluster_res_name_dependencies (res_name, *args)
#cluster_group('add','Testing')
#cluster_res('add','ip2','IP Address','Testing')
#cluster_res('remove','ip2','IP Address','Testing')
#cluster_res_ip_props('myresource',"30.3.4.156","255.255.255.0","30.3.4.0",'1')
#cluster_res_ip_props ('myresource', 'mygroup', '30.3.4.156', '255.255.255.0', 'C_MGMT-304', 1)

#varPropNames = Array( "Address", "SubnetMask", "Network", "EnableNetBIOS" )

  #
  # 
  # gimme the ole methods - puts cluster.ole_methods
