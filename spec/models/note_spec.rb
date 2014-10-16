require 'spec_helper'

describe Dradis::Core::Note do
  before(:each) do
    @category = Dradis::Core::Category.create!(:name => "test_category")
    @node     = Dradis::Core::Node.create!(:label => 'rspec test')
    @note     = Dradis::Core::Note.new
  end

  it "shouldn't fail when text, cat and node are passed" do
    @note.should_not be_valid
    @note.text = 'rspec text'
    @note.node = @node
    @note.category = @category

    @note.should be_valid
  end

  it "should not allow a new note without a valid category" do
    # we are just concerned with :category in this case
    @note.text = 'rspec text'
    @note.node = @node

    @note.should_not be_valid
    @note.should have(1).error_on(:category)
    @note.errors[:category].first.should == "can't be blank"
    @note.category = @category
    @note.should be_valid
  end

  it "should not allow a new note without a valid node" do
    # we are just concerned with the :node field in this case
    @note.text = 'rspec text'
    @note.category = @category
    
    @note.should_not be_valid
    @note.should have(1).error_on(:node)
    @note.errors[:node].first.should == "can't be blank"
    @note.node = @node
    @note.should be_valid
  end

  it "should split a text field into a name/value hash" do
    note = Factory.create(:note)
    note.text =<<EON
#[Title]#
RSpec Title

#[Description]#
Nothing to see here, move on!
EON
    note.save

    note.fields.should have(2).values
    note.fields.keys.should include('Title')
    note.fields.keys.should include('Description')
    note.fields['Title'].should == "RSpec Title"
    note.fields['Description'].should == "Nothing to see here, move on!"
  end

  describe '.search' do
    it 'searches for notes in the database according to keyword' do
      notes_1 = FactoryGirl.create_list(:note, 3, text: 'Note 1')
      note_2 = FactoryGirl.create(:note, text: 'Note 2')

      search_results = Dradis::Core::Note.search('Note 1')
      expect(search_results).to have(3).items
      expect(search_results).to_not include note_2
      expect(search_results).to eq notes_1
    end

    it 'searches for notes case insensitively' do
      note_1 = FactoryGirl.create(:note, text: 'NOTe 1')

      search_results = Dradis::Core::Note.search('note 1')
      expect(search_results).to have(1).item
      expect(search_results).to include note_1
    end

    it 'excludes issues when searching for notes' do
      note_1 = FactoryGirl.create(:note, text: 'Note 1')
      issue_1 = FactoryGirl.create(:issue, text: 'Note 1')

      search_results = Dradis::Core::Note.search('note 1')
      expect(search_results).to have(1).item
      expect(search_results).to include note_1
      expect(search_results).to_not include issue_1
    end
  end
end
