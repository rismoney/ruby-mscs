require 'win32ole'
$cluster = WIN32OLE.new('MSCluster.Cluster')
$cluster.open('cc-fs01a')

def clustergroup (groupname)
  $cluster.resourcegroups.createitem(groupname)
  #cluster.resourcegroups.deleteitem(groupbname)
end
  
def cluster_res(res_name, res_type, res_grp)
  $cluster.Resources.CreateItem(res_name, res_type, res_grp, rm=0)
end

def cluster_res_ip_props (res_name, ip_addr, ip_subnetmask, ip_network, netbios=1)
  $cluster.Resources.item(res_name).PrivateProperties.item('Address').Value = ip_addr
  $cluster.Resources.item(res_name).PrivateProperties.item('SubnetMask').Value = ip_subnetmask
  $cluster.Resources.item(res_name).PrivateProperties.item('Network').Value = ip_network
  $cluster.Resources.item(res_name).PrivateProperties.item('EnableNetBIOS').Value = ip_netbios
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_name_props (res_name, name_RemapPipeNames)
  $cluster.Resources.item(res_name).PrivateProperties.item('Name').Value = res_name
  $cluster.Resources.item(res_name).PrivateProperties.item('RemapPipeNames').Value = RemapPipeNames
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

#def cluster_res_name_dependencies (res_name, *args)


  



#clustergroup "Testing"
#cluster_res('ip2','IP Address','Testing')
#cluster_res_ip_props('ip2','30.3.4.156','255.255.255.0','30.3.4.1')


#varPropNames = Array( "Address", "SubnetMask", "Network", "EnableNetBIOS" )

  #
  # 
  # gimme the ole methods - puts cluster.ole_methods
  
