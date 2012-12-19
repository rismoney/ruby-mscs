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
end