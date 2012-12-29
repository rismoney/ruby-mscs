# cluster_group_spec.rb
require 'win32ole'
require 'mscs'

describe "cluster_group" do

  myname="deleteme"
  clunames = [
  'cc-fs01a',
  ].each do |cluname|
    context "when clustername is #{cluname}" do
    
      context "and myname #{myname}" do
        before :all do
          @cluster = WIN32OLE.new('MSCluster.Cluster')
          @cluster.open(cluname)
          cluster_group('add',myname)
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
