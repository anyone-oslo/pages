# encoding: utf-8

require 'spec_helper'

describe User do
  it { should belong_to(:creator) }
  it { should have_many(:created_users) }
  it { should have_many(:pages) }
  it { should have_many(:roles) }
  it { should belong_to(:image) }

  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:realname) }

  it { should validate_uniqueness_of(:username).case_insensitive }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should allow_value("test@example.com").for(:email) }
  it { should allow_value("test+foo@example.com").for(:email) }
  it { should_not allow_value("foo").for(:email) }

  it { should allow_value("long enough").for(:password) }
  it { should_not allow_value("eep").for(:password) }
end