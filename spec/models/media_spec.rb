require 'rails_helper'

RSpec.describe AtomicCms::Media, type: :model do
  it_behaves_like 'media upload'
end
