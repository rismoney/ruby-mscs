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

require 'Win32API'

cluster_name = "cx-fs01\000".encode('UTF-16LE')

OpenCluster = Win32API.new('clusapi','OpenCluster',['P'], 'L')
hCluster = OpenCluster.call(cluster_name)


group_name = "testing".encode('UTF-16LE')
CreateClusterGroup = Win32API.new('clusapi','CreateClusterGroup',['L','P'], 'L')

hCluster = OpenCluster.call(cluster_name)
CreateClusterGroup.call(hCluster,group_name)

resource_name = ""
resource_type = ""
# if hCluster!=0
  # hGroup = CreateClusterGroup.call(hCluster,group_name)
  # if hGroup!=0
    # hRes = CreateClusterResource.call(hGroup,resource_name,resource_type,0)
      # if hRes!=0
        # OnlineClusterGroup.call(hGroup,0)
        # OfflineClusterGroup.call(hGroup)
        # DeleteClusterResource.call(hRes)
        # CloseClusterResource.call(hRes)
      # end
    # DeleteClusterGroup.call(hGroup)
    # CloseClusterGroup.call(hGroup)
  # end
  # CloseCluster.call(hCluster)
# end




require 'Win32API'
OpenCluster = Win32API.new('clusapi','OpenCluster',['P'], 'L')
ClusterOpenEnum = Win32API.new('clusapi','ClusterOpenEnum',['L','L'], 'L')
ClusterEnum = Win32API.new('clusapi','ClusterEnum',['L','L','P','P','P'], 'L')
cluster_name = "cx-fs01\000".encode('UTF-16LE')

$hCluster = OpenCluster.call(cluster_name)
hEnum = ClusterOpenEnum.call($hCluster,8)


buf=(0.chr*260).encode('UTF-16LE')
buf2=(0.chr*260).encode('UTF-16LE')

size='260'.encode('UTF-16LE')
grouplist = []
i=0

until ClusterEnum.call(hEnum,i,buf,buf2,size) !=0
  bufferlength=size.unpack('L').first
  
  groupname=buf2.slice(0..bufferlength).encode('US-ASCII').strip
  grouplist << groupname
  
  
  size='260'.encode('UTF-16LE')
  
  i += 1
end
