# frozen_string_literal: true
module AtomicCms
  class Video < Media
    validates_attachment :file, presence: true,
                                content_type: { content_type: /\Avideo/ }
  end
end
