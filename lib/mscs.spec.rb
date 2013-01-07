# cluster_group_spec.rb


require 'win32ole'
require './mscs'

cluname = 'cx-fs01'
myname= 'deleteme'
existingnode='cc-fs01a'
existinggroup='Cluster Group'
existingresource='Cluster Name'
existingresourceitem='Cluster IP Address'
newfakegroup='blah'
newfakeresource='myfakeres'

# the rspec purposely uses win32ole com to validate the settings
# i use it to avoid api code calls for query.  may change to wmi
# at later point.

cluster = WIN32OLE.new('MSCluster.Cluster')
cluster.open(cluname)
  
describe "cluster_open" do
  context "when clustername is #{cluname}" do
    opensesame=Mscs::Cluster.open('Cluster',cluname)
      it "should be a fixnum" do 
        opensesame.should be_a_kind_of(Fixnum)
      end
      it "fixnum should have a non zero fixnum value if successful connection " do 
        opensesame.should be > 0
      end
      it do 
        expect(Mscs::Cluster.open('Cluster','nonexistant')).to eq 0
      end
  end
end

describe "cluster_enumeration" do
  context "when clustername is #{cluname}" do
    before :all do
      $opensesame=Mscs::Cluster.open('Cluster',cluname)
      $enumgroup=Mscs::Cluster.enumerate('Cluster',$opensesame, 8)
      $enumnodes=Mscs::Cluster.enumerate('Cluster',$opensesame, 1)
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
    before :all do
      $opensesame=Mscs::Cluster.open('Cluster',cluname)
    end
    it "creates a cluster resource group" do
      Mscs::Group.add($opensesame, newfakegroup)
      cluster.resourcegroups.item(newfakegroup).Name.should eq(newfakegroup)
    end
    it "query a specific resource group" do
      groupquery=Mscs::Group.query($opensesame, existinggroup)
      groupquery.should be_a_kind_of(Array)
      groupquery.should include(existingresource)
      
    end
    it "deletes a cluster resource group" do
      Mscs::Group.remove($opensesame,newfakegroup)
      expect {cluster.resourcegroups.item(newfakegroup)}.to raise_error
    end
  end
end

describe "cluster resource" do
  context "when clustername is #{cluname}" do
    before :all do
      $opensesame=Mscs::Cluster.open('Cluster',cluname)
      Mscs::Group.add($opensesame, newfakegroup)
    end
  it "creates a cluster resource" do
     
      Mscs::Resource.add($opensesame, newfakeresource, 'IP Address', newfakegroup)
      cluster.resources.item(newfakeresource).Name.should eq(newfakeresource)
    end
    it "query a specific resource" do
      resquery=Mscs::Resource.query($opensesame, existingresource)
      resquery.should be_a_kind_of(Array)
      resquery.should include(existingresourceitem)
    end
    it "deletes the resource just created specific resource" do
      removal=Mscs::Resource.remove($opensesame,newfakeresource)
      removal.should eq(0)
    end
  end
end