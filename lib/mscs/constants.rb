module Mscs::Constants
  private

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

  #http://msdn.microsoft.com/en-us/library/windows/desktop/bb309156(v=vs.85).aspx
  CLUSTER_NODE_ENUM_NETINTERFACES  = 0x00000001,
  CLUSTER_NODE_ENUM_GROUPS         = 0x00000002,

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
end