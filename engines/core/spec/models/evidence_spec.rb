require 'spec_helper'

describe Dradis::Core::Evidence do
  it "needs to be tied to an Issue" do
    node = FactoryGirl.create(:node)
    issue = FactoryGirl.create(:issue)
    evidence = Dradis::Core::Evidence.new(:node_id => node.id)

    evidence.should_not be_valid
    evidence.issue = issue
    evidence.should be_valid
    evidence.save
    evidence.reload
    evidence.issue.should eq(issue)
  end
  it "needs to be tied to a Node" do
    node = FactoryGirl.create(:node)
    issue = FactoryGirl.create(:issue)
    evidence = Dradis::Core::Evidence.new(:issue_id => issue.id)

    evidence.should_not be_valid
    evidence.node = node
    evidence.should be_valid
    evidence.save
    evidence.reload
    evidence.node.should eq(node)
  end
  it "provides access to the Node label's as a virtual field" do
    issue = FactoryGirl.create(:issue)
    node = FactoryGirl.create(:node)
    evidence = Dradis::Core::Evidence.new(:node_id => node.id, :issue_id => issue.id, :content => "#[Output]#\nResistance is futile\n\n")

    evidence.fields['Label'].should eq(node.label)
  end

  describe '.search' do
    it 'searches for evidence in the database according to keyword' do
      evidence_1 = FactoryGirl.create_list(:evidence, 3, content: 'Evidence 1')
      evidence_2 = FactoryGirl.create(:evidence, content: 'Evidence 2')

      search_results = Dradis::Core::Evidence.search('Evidence 1')
      expect(search_results).to have(3).items
      expect(search_results).to_not include evidence_2
      expect(search_results).to eq evidence_1
    end

    it 'searches for evidence case insensitively' do
      evidence_1 = FactoryGirl.create(:evidence, content: 'evidence 1')

      search_results = Dradis::Core::Evidence.search('evidence 1')
      expect(search_results).to have(1).item
      expect(search_results).to include evidence_1
    end
  end
end
