require 'spec_helper'

describe Dradis::Frontend::SearchController, :type => :controller do
  describe 'as guest' do
    before { allow(controller).to receive(:authenticated?).and_return(false) }

    it 'should require authentication for search' do
      get :search
      response.should redirect_to(login_path)
      flash[:alert].should == 'Please sign in first. Access denied.'
    end
  end

  describe 'as user' do
    before { allow(controller).to receive(:login_required) }

    context 'when keyword is "Random"' do
      before do
        expect(Dradis::Core::Note).to receive(:search).and_return(FactoryGirl.build_list(:note, 2))
        expect(Dradis::Core::Issue).to receive(:search).and_return([])
        expect(Dradis::Core::Evidence).to receive(:search).and_return(FactoryGirl.build_list(:evidence, 1))

        get :search, q: 'Random'
      end

      it 'should return results from all searchable models' do
        notes = assigns(:notes)
        issues = assigns(:issues)
        evidence = assigns(:evidence)

        expect(notes).to have(2).item
        expect(issues).to have(0).item
        expect(evidence).to have(1).item
      end
    end

    context 'when keyword is "random is:Evidence"' do
      before do
        expect(Dradis::Core::Note).to_not receive(:search)
        expect(Dradis::Core::Issue).to_not receive(:search)
        expect(Dradis::Core::Evidence).to receive(:search).and_return(FactoryGirl.build_list(:evidence, 1))

        get :search, q: 'random is:Evidence'
      end

      it 'should return results only from Evidence models' do
        notes = assigns(:notes)
        issues = assigns(:issues)
        evidence = assigns(:evidence)

        expect(notes).to be_nil
        expect(issues).to be_nil
        expect(evidence).to have(1).item
      end
    end

    context 'when keyword is "Reminder is:note is:issue"' do
      before do
        expect(Dradis::Core::Note).to receive(:search).and_return(FactoryGirl.build_list(:note, 2))
        expect(Dradis::Core::Issue).to receive(:search).and_return(FactoryGirl.build_list(:issue, 1))
        expect(Dradis::Core::Evidence).to_not receive(:search)

        get :search, q: 'random is:note is:issue'
      end

      it 'should return results from both Note and Issue models' do
        notes = assigns(:notes)
        issues = assigns(:issues)
        evidence = assigns(:evidence)

        expect(notes).to have(2).item
        expect(issues).to have(1).item
        expect(evidence).to be_nil
      end
    end
  end
end
