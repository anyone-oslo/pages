# frozen_string_literal: true

require "rails_helper"

describe PagesCore::ErrorReporting do
  controller(ApplicationController) do
    def index
      head :ok
    end
  end

  let(:sentry) { double(set_context: nil, set_tags: nil, set_user: nil) }
  let(:params) do
    { password: "hunter2", otp: "123456", token: "abc", signed_message: "msg",
      signed_user_id: "uid", locale: "nb" }
  end

  before do
    stub_const("Sentry", sentry)
    allow(Rails.env).to receive(:test?).and_return(false)
    get :index, params:
  end

  %w[password otp token signed_message signed_user_id].each do |name|
    it "filters #{name}" do
      expect(sentry).to have_received(:set_context)
        .with("params", hash_including(name => "[FILTERED]"))
    end
  end

  it "keeps non-sensitive params" do
    expect(sentry).to have_received(:set_context)
      .with("params", hash_including("locale" => "nb"))
  end
end
