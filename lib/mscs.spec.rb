# cluster_group_spec.rb


require 'win32ole'
require 'mscs'

cluname = 'cx-fs01'
myname= 'deleteme'
existingnode='cc-fs01a'
existinggroup='Cluster Group'
newfakegroup='blah'

# the rspec purposely uses win32ole com to validate the settings
# i use it to avoid api code calls for query.  may change to wmi
# at later point.

cluster = WIN32OLE.new('MSCluster.Cluster')
cluster.open(cluname)
  
describe "cluster_open" do
  context "when clustername is #{cluname}" do
    opensesame=cluster_open(cluname)
      it "should be a fixnum" do 
        opensesame.should be_a_kind_of(Fixnum)
      end
      it "fixnum should have a non zero fixnum value if successful connection " do 
        opensesame.should be > 0
      end
      it do 
        expect(cluster_open('nonexistant')).to eq 0
      end
  end
end

describe "cluster_enumeration" do
  context "when clustername is #{cluname}" do
    before :all do
      $opensesame=cluster_open(cluname)
      $enumgroup=cluster_enumeration('Cluster',$opensesame, 8)
      $enumnodes=cluster_enumeration('Cluster',$opensesame, 1)
    end
    it "should query all the cluster groups cluster and return array" do 
      $enumgroup.should be_a_kind_of(Array)
    end
    it "should contain default cluster group" do 
      $enumgroup.should include(existinggroup)
    end
    it "should contain nodes" do 
      $enumnodes.should include(existingnode)
    end
  end
end

describe "cluster_group" do
  context "when clustername is #{cluname}" do
    context "and myname #{myname}" do
      # after :all do
        # cluster.resourcegroups.deleteitem(myname)
      # end
      it "creates a cluster resource group" do
        cluster_group('add',newfakegroup, $opensesame)
        cluster.resourcegroups.item(newfakegroup).Name.should eq(newfakegroup)
      end
      it "deletes a cluster resource group" do
        cluster_group('remove',newfakegroup, $opensesame)
        expect {cluster.resourcegroups.item(newfakegroup)}.to raise_error
      end      
    end
  end
end