require 'win32ole'
$cluster = WIN32OLE.new('MSCluster.Cluster')
$cluster.open('cc-fs01a')

def cluster_group (action,groupname)
  case action
    when "add"
      $cluster.resourcegroups.createitem(groupname)
    when "remove"
      cluster.resourcegroups.deleteitem(groupname)
    end  
end
  
def cluster_res(action, res_name, res_type, res_grp)
  case action
    when "add"
      $cluster.Resources.CreateItem(res_name, res_type, res_grp, rm=0)
    when "remove"
      $cluster.Resources.DeleteItem(res_name)
    end
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

def cluster_res_fileshare_props (res_name, fs_path, fs_sharename, fs_remark, fs_sharesubdir)
  $cluster.Resources.item(res_name).PrivateProperties.item('Name').Value = res_name
  $cluster.Resources.item(res_name).PrivateProperties.item('Path').Value = fs_path
  $cluster.Resources.item(res_name).PrivateProperties.item('ShareName').Value = fs_sharename
  $cluster.Resources.item(res_name).PrivateProperties.item('Remark').Value = fs_remark
  $cluster.Resources.item(res_name).PrivateProperties.item('ShareSubDirs').Value = fs_sharesubdir
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_gensvc_props (res_name, gs_servicename, gs_startupparams, gs_usenetworkname)
  $cluster.Resources.item(res_name).PrivateProperties.item('ServiceName').Value = gs_servicename
  $cluster.Resources.item(res_name).PrivateProperties.item('StartupParameters').Value = gs_startupparams
  $cluster.Resources.item(res_name).PrivateProperties.item('ShareName').Value = gs_usenetworkname
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_pdisk_props (res_name, pd_signature, pd_skipchkdsk, pd_cdtlmount)
  $cluster.Resources.item(res_name).PrivateProperties.item('Signature').Value = pd_signature
  $cluster.Resources.item(res_name).PrivateProperties.item('SkipChkdsk').Value = pd_skipchkdsk
  $cluster.Resources.item(res_name).PrivateProperties.item('ConditionalMount').Value = pd_cdtlmount
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_res_genapp_props (res_name, ga_commandline, ga_currentdir, ga_interactive, ga_usenetworkname)
  $cluster.Resources.item(res_name).PrivateProperties.item('CommandLine').Value = ga_commandline
  $cluster.Resources.item(res_name).PrivateProperties.item('CurrentDirectory').Value = ga_currentdir
  $cluster.Resources.item(res_name).PrivateProperties.item('InteractWithDesktop').Value = ga_interactive
  $cluster.Resources.item(res_name).PrivateProperties.item('UseNetworkName').Value = ga_usenetworkname
  $cluster.Resources.item(res_name).PrivateProperties.savechanges
end

def cluster_mod_dependency (action, res_name, dependencyname)
  resource = $cluster.Resources.item(res_name)
  dependency = $cluster.Resources.item(dependencyname)

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
#clustergroup "Testing"
#cluster_res('add','ip2','IP Address','Testing')
#cluster_res('remove','ip2','IP Address','Testing')
#cluster_res_ip_props('ip2','30.3.4.156','255.255.255.0','30.3.4.1')


#varPropNames = Array( "Address", "SubnetMask", "Network", "EnableNetBIOS" )

  #
  # 
  # gimme the ole methods - puts cluster.ole_methods
