# encoding: utf-8

require 'spec_helper'

describe Page do

  describe ".archive_finder" do
    subject { Page.archive_finder }
    it { should be_a(PagesCore::ArchiveFinder) }
    its(:timestamp_attribute) { should == :published_at }
  end

  describe ".published" do
    let!(:published_page) { create(:page) }
    let!(:hidden_page) { create(:page, status: 3) }
    let!(:autopublish_page) { create(:page, published_at: (Time.now + 2.hours)) }
    subject { Page.published }
    it { should include(published_page) }
    it { should_not include(hidden_page) }
    it { should_not include(autopublish_page) }
  end

  describe ".localized" do
    let!(:norwegian_page) { Page.create(name: 'Test', locale: 'nb') }
    let!(:english_page) { Page.create(name: 'Test', locale: 'en') }
    subject { Page.localized('nb') }
    it { should include(norwegian_page) }
    it { should_not include(english_page) }
  end

  describe ".locales" do
    let(:page) { Page.create(:excerpt => {'en' => 'My test page', 'nb' => 'Testside'}, :locale => 'en') }
    subject { page.locales }
    it { should =~ ['en', 'nb'] }
  end

  describe 'with ancestors' do
    let(:root)   { Page.create }
    let(:parent) { Page.create(:parent => root) }
    let(:page)   { Page.create(:parent => parent) }

    it 'belongs to the parent' do
      page.parent.should == parent
    end

    it 'is a child of root' do
      page.ancestors.should include(root)
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

    it 'should remove the unnecessary locales' do
      page.locales.should =~ ['en', 'nb']
      page.update(excerpt: '')
      page.locales.should =~ ['nb']
    end
  end

  it 'should return a blank Localization for uninitialized columns' do
    page = Page.new
    page.body?.should be_false
    page.body.should be_a(String)
  end

  describe 'with an excerpt' do
    let(:page) { Page.create(:excerpt => 'My test page', :locale => 'en') }

    it 'responds to excerpt?' do
      page.excerpt?.should be_true
      page.excerpt = nil
      page.excerpt?.should be_false
    end

    it 'excerpt should be a localization' do
      page.excerpt.should be_kind_of(String)
      page.excerpt.to_s.should == 'My test page'
    end

    it 'should be changed when saved' do
      page.update(:excerpt => 'Hi')
      page.reload
      page.excerpt.to_s.should == 'Hi'
    end

    it 'should remove the localization when nilified' do
      page.update(:excerpt => nil)
      page.valid?.should be_true
      page.reload
      page.excerpt?.should be_false
    end
  end
end
