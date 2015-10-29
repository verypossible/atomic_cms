module AtomicCms
  class Media < ActiveRecord::Base
    self.inheritance_column = "media_type"

    has_attached_file :file
    do_not_validate_attachment_file_type :file

    def self.available_types
      descendants.map { |desc| desc.name.demodulize }
    end
  end
end
