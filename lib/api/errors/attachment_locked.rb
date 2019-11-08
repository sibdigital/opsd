module API
  module Errors
    class AttachmentLocked < ErrorBase
      identifier 'urn:openproject-org:api:v3:errors:AttachmentLocked'

      def initialize(username)
        super 403, I18n.t('api_v3.errors.code_403_attachment') + ' ' + username
      end
    end
  end
end
