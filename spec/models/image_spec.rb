require 'rails_helper'

describe AtomicCms::Image do
  it_behaves_like 'media upload'

  context 'file validations' do
    it { should validate_attachment_presence(:file) }
    it 'validates the content types' do
      should validate_attachment_content_type(:file)
        .allowing('image/png', 'image/gif', 'image/jpg')
    end
  end
end
