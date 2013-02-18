module Sape
  module Helpers
    def sape_links(num = nil)
      Sape::Processor.from_request(Sape::Railtie.config(:user_id), request).links(num).html_safe
    end
  end
end

