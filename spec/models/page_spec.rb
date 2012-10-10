require 'spec_helper'

describe Page do
  describe 'with ancestors' do
    let(:root)   { Page.create }
    let(:parent) { Page.create(:parent => root) }
    let(:page)   { Page.create(:parent => parent) }

    it 'belongs to the parent' do
      page.parent.should == parent
    end

    it 'is a child of root' do
      page.is_child_of(root).should be_true
    end

    it 'has both as ancestors' do
      page.ancestors.should == [parent, root]
    end

    it 'has a root page' do
      page.root.should == root
    end
  end

  describe 'setting multiple locales' do
    let(:page) { Page.create(:excerpt => {'en' => 'My test page', 'nb' => 'Testside'}, :locale => 'en') }

    it 'should respond with the locale specific string' do
      page.excerpt?.should be_true
      page.excerpt.to_s.should == 'My test page'
      page.localize('nb').excerpt.to_s.should == 'Testside'
    end
  end

  it 'should return a blank Localization for uninitialized columns' do
    page = Page.new
    page.body?.should be_false
    page.body.should be_a(Localization)
  end

  describe 'with an excerpt' do
    let(:page) { Page.create(:excerpt => 'My test page', :locale => 'en') }

    it 'responds to excerpt?' do
      page.excerpt?.should be_true
      page.excerpt = nil
      page.excerpt?.should be_false
    end

    it 'excerpt should be a localization' do
      page.excerpt.should be_kind_of(Localization)
      page.excerpt.to_s.should == 'My test page'
    end

    it 'should be changed when saved' do
      page.update_attribute(:excerpt, 'Hi')
      page.reload
      page.excerpt.to_s.should == 'Hi'
    end

    it 'should remove the localization when nilified' do
      page.update_attribute(:excerpt, nil)
      page.valid?.should be_true
      page.reload
      page.excerpt?.should be_false
    end
  end
end