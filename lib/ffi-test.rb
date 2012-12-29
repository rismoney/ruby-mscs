require 'ffi'

module Win
  
  extend FFI::Library
  ffi_lib 'clusapi'
  ffi_convention :stdcall

  attach_function :OpenCluster, [ :pointer ], :int
  attach_function :CreateClusterGroup, [ :long, :pointer], :int

end

  cluster_name = "cx-fs01\000".encode('UTF-16LE')
  cluster_group = "test\000".encode('UTF-16LE')
  
  title=Win.OpenCluster(cluster_name);
  
  Win.CreateClusterGroup(title,cluster_group);
  title=FFI::MemoryPointer.from_string(title)
  
  p title

  


