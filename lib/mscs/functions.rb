require "win32ole"
require "Win32API"

module Mscs::Functions

  lstrcpyW = Win32API.new('kernel32','lstrcpyW',['P','L'],'P')

  
  #opens
  OpenCluster = Win32API.new('clusapi','OpenCluster',['P'], 'L')
  OpenClusterGroup = Win32API.new('clusapi','OpenClusterGroup',['L','P'], 'L')
  OpenClusterResource = Win32API.new('clusapi','OpenClusterResource',['L','P'], 'L')
  OpenClusterNetwork = Win32API.new('clusapi','OpenClusterNetwork',['L','P'], 'L')
  OpenClusterNode = Win32API.new('clusapi','OpenClusterNode',['L','P'], 'L')

  #closes
  CloseClusterResource = Win32API.new('clusapi','CloseClusterResource',['L'], 'L')
  CloseClusterGroup = Win32API.new('clusapi','CloseClusterGroup',['L'], 'L')
  CloseCluster = Win32API.new('clusapi','CloseCluster',['L'], 'L')

  #enums clusters
  GetClusterInformation = Win32API.new('clusapi','GetClusterInformation',['L','P','P','P'], 'L')
  ClusterOpenEnum = Win32API.new('clusapi','ClusterOpenEnum',['L','L'], 'L')
  ClusterEnum = Win32API.new('clusapi','ClusterEnum',['L','L','P','P','P'], 'L')

  #enum group
  ClusterGroupOpenEnum = Win32API.new('clusapi','ClusterGroupOpenEnum',['L','L'], 'L')
  ClusterGroupEnum = Win32API.new('clusapi','ClusterGroupEnum',['L','L','P','P','P'], 'L')

  # enum resource
  ClusterResourceOpenEnum = Win32API.new('clusapi','ClusterResourceOpenEnum',['L','L'], 'L')
  ClusterResourceEnum = Win32API.new('clusapi','ClusterResourceEnum',['L','L','P','P','P'], 'L')

  # enum cluster network
  ClusterNetworkOpenEnum = Win32API.new('clusapi','ClusterResourceOpenEnum',['L','L'], 'L')
  ClusterNetworkEnum = Win32API.new('clusapi','ClusterResourceEnum',['L','L','P','P','P'], 'L')

  ClusterNodeOpenEnum = Win32API.new('clusapi','ClusterResourceOpenEnum',['L','L'], 'L')
  ClusterNodeEnum = Win32API.new('clusapi','ClusterResourceEnum',['L','L','P','P','P'], 'L')

  #create-delete
  CreateCluster = Win32API.new('clusapi','CreateCluster',['L','P','P'], 'L')
  DestroyCluster = Win32API.new('clusapi','DestroyCluster',['L','P','P','L'], 'L')
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
  AddClusterResourceDependency = Win32API.new('clusapi','AddClusterResourceDependency',['L','L'], 'L')
  CanResourceBeDependent = Win32API.new('clusapi','CanResourceBeDependent',['L','L'], 'L')
  RemoveClusterResourceDependency = Win32API.new('clusapi','RemoveClusterResourceDependency',['L','L'], 'L')

end