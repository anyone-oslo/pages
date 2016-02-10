require "rails_helper"

describe PagesCore::ExceptionHandler, type: :controller do
  let(:reports_path) { Rails.root.join("log/error_reports") }

  controller(ApplicationController) do
    include PagesCore::ExceptionHandler
    include PagesCore::ExceptionHandler::Rescues

    def exception
      raise Exception, "An error occurred"
    end

    def not_authorized
      raise PagesCore::NotAuthorized
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end
  end

  before do
    routes.draw do
      get "exception" => "anonymous#exception"
      get "not_authorized" => "anonymous#not_authorized"
      get "not_found" => "anonymous#not_found"
    end
  end

  after do
    FileUtils.rm_rf(reports_path) if File.exist?(reports_path)
  end

  describe "Exception" do
    let(:error_id) { assigns(:error_id) }
    let(:error_file) { reports_path.join("#{error_id}.yml") }
    let(:report) { YAML.load_file(error_file) }

    before { get :exception }
    it { is_expected.to render_template("errors/500") }

    it "should write an exception report" do
      expect(error_id).to be_a(String)
      expect(File.exist?(error_file)).to eq(true)
      expect(report[:url]).to eq("http://test.host")
      expect(report[:message]).to eq("An error occurred")
    end
  end

  describe "Not authorized" do
    before { get :not_authorized }
    it { is_expected.to render_template("errors/403") }
  end

  describe "Record not found" do
    before { get :not_found }
    it { is_expected.to render_template("errors/404") }
  end
end
