# cluster_group_spec.rb


require 'win32ole'
require './mscs'

################ configuration block configuration block - no
server='cc-git01'
cluster_name='cc-git01x'


cluster_ipaddress=['30.3.4.43']
cluster_subnetmask=['255.255.255.0']
cluster_nodes=['cc-git01']
domain='nyise'
kerb_name="#{domain}\\#{server}"

cluster_existingnode=cluster_nodes.first
cluster_existinggroup='Cluster Group'
cluster_existingresource='Cluster Name'
cluster_existingresourceip='Cluster IP Address'
cluster_existingresource_privprop='255.255.255.0'
cluster_newgroup='newgroup'
cluster_newres1='newres1'
cluster_newres2='newres2'

ipres={
        :enabledhcp    => 0,
        :address       => '30.3.4.42',
        :subnetmask    => '255.255.255.0',
        :network       => 'Cluster Network 1',
        :enablenetbios => 0
        }

# the rspec purposely uses win32ole com to validate the settings
# i use it to avoid api code calls for query.  may change to wmi
# at later point.

############### config block end

describe "cluster_enumeration" do
  context "when clustername is #{cluster_name}" do
    before :all do
      $opensesame=Mscs::Cluster.open('Cluster',server)
      $enumgroup=Mscs::Cluster.enumerate('Cluster',$opensesame, 8)
      $enumnodes=Mscs::Cluster.enumerate('Cluster',$opensesame, 1)
    end
    it "should query all the cluster groups cluster and return array" do 
      $enumgroup.should be_a_kind_of(Array)
    end
    it "should contain default cluster group" do 
      $enumgroup.should include(cluster_existinggroup)
    end
    it "should contain nodes" do 
      $enumnodes.should include(cluster_existingnode.upcase)
    end
  end
end

describe "cluster_open" do
  context "when clustername is #{cluster_name}" do
    $opensesame=Mscs::Cluster.open('Cluster',server)
      it "should be a fixnum" do 
        $opensesame.should be_a_kind_of(Fixnum)
      end
      it "fixnum should have a non zero fixnum value if successful connection " do 
        $opensesame.should be > 0
      end
      it do 
        expect(Mscs::Cluster.open('Cluster','nonexistant')).to eq 0
      end
  end
end

describe "cluster_group" do
  context "when clustername is #{cluster_name}" do
    before :all do
      $opensesame=Mscs::Cluster.open('Cluster',server)
      # hack #1
      $cluster = WIN32OLE.new('MSCluster.Cluster')
      $cluster.open(server)
    end
    it "creates a cluster resource group" do
      Mscs::Group.add($opensesame, cluster_newgroup)
      $cluster.resourcegroups.item(cluster_newgroup).Name.should eq(cluster_newgroup)
    end
    it "query a specific resource group" do
      groupquery=Mscs::Group.query($opensesame, cluster_existinggroup)
      groupquery.should be_a_kind_of(Array)
      groupquery.should include(cluster_existingresource)
      
    end
    it "deletes a cluster resource group" do
      removal=Mscs::Group.remove($opensesame,cluster_newgroup)
      removal.should eq(0)
      #expect {cluster.resourcegroups.item(cluster_newgroup)}.to raise_error
    end
  end
end