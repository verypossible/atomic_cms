module AtomicCms
  class Image < Media
    validates_attachment :file, presence: true,
                                content_type: { content_type: /\Aimage/ }
  end
end
