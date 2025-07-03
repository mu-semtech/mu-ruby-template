require_relative '../mu.rb'

describe 'helpers' do
  subject { Mu::Helpers }
  describe 'validate_json_api_content_type' do
    context 'when Content-Type is JSONAPI (application/vnd.api+json)' do
      it 'does not respond with an error' do
        valid_request = Object.new
        expect(valid_request).to receive(:env).and_return('CONTENT_TYPE' => "application/vnd.api+json")
        expect(subject).not_to receive(:error)
        subject.validate_json_api_content_type(valid_request)
      end
    end
    context 'when Content-Type is JSONAPI with media types' do
      it 'does not respond with an error' do
        request = Object.new
        expect(request).to receive(:env).and_return('CONTENT_TYPE' => "application/vnd.api+json;charset=UTF-8")
        expect(subject).not_to receive(:error)
        subject.validate_json_api_content_type(request) 
      end
    end
    context 'when Content-Type is not JSONAPI' do
      it 'returns an error' do
        invalid_request = Object.new
        expect(invalid_request).to receive(:env).twice.and_return('CONTENT_TYPE' => "application/json")
        expect(subject).to receive(:error)
        subject.validate_json_api_content_type(invalid_request)
      end
    end
  end
end
