require 'spec_helper'

describe Saml::Response do

  let(:response) { build(:response) }

  it "Should be a StatusResponseType" do
    Saml::Response.ancestors.should include Saml::ComplexTypes::StatusResponseType
  end

  describe "Optional fields" do
    [:assertion].each do |field|
      it "should have the #{field} field" do
        response.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        response.send("#{field}=", nil)
        response.errors.entries.should == [] #be_valid
        response.send("#{field}=", "")
        response.errors.entries.should == [] #be_valid
      end
    end
  end

  describe "parse" do
    let(:response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:response) { Saml::Response.parse(response_xml, :single => true) }

    it "should parse the Response" do
      response.should be_a(Saml::Response)
    end

    it "should parse the Assertion" do
      response.assertion.should be_a(Saml::Assertion)
    end

    it "should parse multiple assertions" do
      response.assertions.first.should be_a(Saml::Assertion)
    end
  end

  describe 'authn_failed?' do
    it 'returns true if sub status is AUTHN_FAILED' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::AUTHN_FAILED))
      response.status = status
      response.authn_failed?.should be_true
    end

    it 'returns false if sub status is not AUTHN_FAILED' do
      response.authn_failed?.should be_false
    end
  end

  describe 'no_authn_context?' do
    it 'returns true if sub status is NO_AUTHN_CONTEXT' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::NO_AUTHN_CONTEXT))
      response.status = status
      response.no_authn_context?.should be_true
    end

    it 'returns false if sub status is not no_authn_context' do
      response.no_authn_context?.should be_false
    end
  end

  describe 'request_denied?' do
    it 'returns true if sub status is AUTHN_FAILED' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::REQUEST_DENIED))
      response.status = status
      response.request_denied?.should be_true
    end

    it 'returns false if sub status is not AUTHN_FAILED' do
      response.request_denied?.should be_false
    end
  end

  describe 'assertions' do
    let(:response) do
      response = Saml::Response.new(assertion: Saml::Assertion.new)
      Saml::Response.parse(Saml::Response.parse(response.to_xml, single: true).to_xml)
    end

    it 'only adds 1 assertion' do
      response.assertions.count.should == 1
    end
  end

end
