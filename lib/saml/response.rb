module Saml
  class Response
    include Saml::ComplexTypes::StatusResponseType

    tag "Response"
    has_many :assertions, Saml::Assertion, :tag => "Assertion"

    def authn_failed?
      !success? && status.status_code.authn_failed?
    end

    def request_denied?
      !success? && status.status_code.request_denied?
    end

    def no_authn_context?
      !success? && status.status_code.no_authn_context?
    end

    def assertion
      assertions.first
    end

    def assertion=(assertion)
      (self.assertions ||= []) << assertion
    end
  end
end
