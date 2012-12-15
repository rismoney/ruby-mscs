# clustergroup_spec.rb
require 'win32ole'
require 'clustergroup'

describe "clustergroup" do

  myname='deleteme'
  clunames = [
  'cc-fs01a',
  'dummy',
  ].each do |cluname|
    context "when clustername is #{cluname}" do
    
      context "and myname #{myname}" do
        before :all do
          @cluster = WIN32OLE.new('MSCluster.Cluster')
          @cluster.open(cluname)
          clustergroup myname
        end
        after :all do
          @cluster.resourcegroups.deleteitem(myname)
        end
        it "creates a cluster resource group" do
          @cluster.resourcegroups.item(myname).Name.should eq(myname)
        end
        it do 
          expect {@cluster.resourcegroups.item('nonexistant')}.to raise_error
        end
      end
    end
  end
end
