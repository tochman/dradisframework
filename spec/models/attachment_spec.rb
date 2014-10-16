require 'spec_helper'

describe Dradis::Core::Attachment do
  set_fixture_class :dradis_configurations => Dradis::Core::Configuration
  fixtures :dradis_configurations

  before(:each) do
  end

  it "should copy the source file into the attachments folder" do
    node = Dradis::Core::Node.create!(:label => 'rspec test')

    attachment = Dradis::Core::Attachment.new( Rails.root.join('public', 'images', 'rails.png'), :node_id => node.id )
    attachment.save
    File.exists?(Dradis::Core::Attachment.pwd + "#{node.id}/rails.png").should be_true

    node.destroy
  end

  it "should be able to find attachments by filename"
  it "should be able to find all attachments for a given node"
  it "should recognise Ruby file IO and in particular the <<() method"
  it "should be re-nameble"
end
