require 'spec_helper'

describe 'dradis/frontend/search/search.html.erb', :type => :view do
  before(:each) do
    @evidence, @notes, @issues = [], [], []
  end
  context 'search results returns @evidence and' do
    before(:each) do
      (0..2).each do |n|
        @evidence << FactoryGirl.build(:evidence, content: "#[Title]#\r\nEvidence #{n}\r\n\r\n#[Description]#\r\nThis is evidence #{n}")
      end
      render
    end

    it 'should render # of results in @evidence' do
      expect(view.content_for(:sidebar)).to have_css 'p', text: 'In Evidence'
      expect(view.content_for(:sidebar)).to have_css 'span.badge', text: '3'
    end

    it 'should render header' do
      expect(rendered).to have_css 'h4', text: 'Found in Evidence'
    end

    it 'should render search results from Evidence' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to have_css 'li h5', text: 'Title'
        expect(selector).to have_css 'li p', text: 'Evidence 0'
        expect(selector).to have_css 'li h5', text: 'Description'
        expect(selector).to have_css 'li p', text: 'This is evidence 0'
      end
    end

    it 'should not display custom format tags in instence' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to_not have_content '#[Title]#'
        expect(selector).to_not have_content '#[Description]#'
      end
    end

  end

  context 'search results returns @notes and' do
    before(:each) do
      (0..2).each do |n|
        @notes << FactoryGirl.build(:note, text: "#[Title]#\r\nNote #{n}\r\n\r\n#[Description]#\r\nThis is note #{n}")
      end
      render
    end

    it 'should render # of results in @notes' do
      expect(view.content_for(:sidebar)).to have_css 'p', text: 'In Notes'
      expect(view.content_for(:sidebar)).to have_css 'span.badge', text: '3'
    end

    it 'should render header' do
      expect(rendered).to have_css 'h4', text: 'Found in Notes'
    end

    it 'should render search results from Notes' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to have_css 'li h5', text: 'Title'
        expect(selector).to have_css 'li p', text: 'Note 0'
        expect(selector).to have_css 'li h5', text: 'Description'
        expect(selector).to have_css 'li p', text: 'This is note 0'
      end
    end

    it 'should not display custom format tags' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to_not have_content '#[Title]#'
        expect(selector).to_not have_content '#[Description]#'
      end
    end


  end

  context 'search results returns @issues and' do
    before(:each) do
      (0..2).each do |n|
        @issues << FactoryGirl.build(:issue, text: "#[Title]#\r\nIssue #{n}\r\n\r\n#[Description]#\r\nThis is issue #{n}")
      end
      render
    end

    it 'should render # of results in @issues' do
      expect(view.content_for(:sidebar)).to have_css 'p', text: 'In Issues'
      expect(view.content_for(:sidebar)).to have_css 'span.badge', text: '3'
    end

    it 'should render header' do
      expect(rendered).to have_css 'h4', text: 'Found in Issues'
    end

    it 'should render search results from Issues' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to have_css 'li h5', text: 'Title'
        expect(selector).to have_css 'li p', text: 'Issue 0'
        expect(selector).to have_css 'li h5', text: 'Description'
        expect(selector).to have_css 'li p', text: 'This is issue 0'
      end
    end

    it 'should not display custom format tags' do
      rendered.within('ul.whatever') do |selector|
        expect(selector).to_not have_content '#[Title]#'
        expect(selector).to_not have_content '#[Description]#'
      end
    end

  end

  context 'no search results are returned' do
    it 'should render message' do
      render
      expect(rendered).to have_css 'h4', text: 'No Results Found'
    end
  end

end