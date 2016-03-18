require_relative '../sinatra_template/helpers.rb'

class MyHelper
  include SinatraTemplate::Helpers
end

describe 'helpers' do
  subject { MyHelper.new }
  describe "validate_json_api_content_type" do
    # FF < 43
    it "should allow media types if a request specifies the header Content-Type: application/vnd.api+json" do
      request = Object.new
      expect(request).to receive(:env).and_return('CONTENT_TYPE' => "application/vnd.api+json;charset=UTF-8")
      expect(subject).not_to receive(:error)
      subject.validate_json_api_content_type(request) 
    end
    it "should allow only application/vnd.api+json as content type" do
      invalid_request = Object.new
      expect(invalid_request).to receive(:env).and_return('CONTENT_TYPE' => "application/json")
      expect(subject).to receive(:error)
      subject.validate_json_api_content_type(invalid_request)
      valid_request = Object.new
      expect(valid_request).to receive(:env).and_return('CONTENT_TYPE' => "application/json")
      expect(subject).not_to receive(:error)
      subject.validate_json_api_content_type(valid_request)
    end
  end
end
