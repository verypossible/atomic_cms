# frozen_string_literal: true
require 'rails_helper'

describe AtomicCms::Video do
  it_behaves_like 'media upload'

  context 'file validations' do
    it { should validate_attachment_presence(:file) }
    it 'validates the content types' do
      should validate_attachment_content_type(:file)
        .allowing('video/mp4', 'video/x-msvideo', 'video/x-ms-wmv')
    end
  end
end
