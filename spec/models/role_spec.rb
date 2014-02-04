# encoding: utf-8

require 'spec_helper'

describe Role do
  let(:role) { create(:role) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }
end