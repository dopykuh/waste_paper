require 'securerandom'

class Entry < ApplicationRecord
  belongs_to :source
  delegate :user, to: :source, allow_nil: true

  attr_accessor :attachment

  before_create :ocr

  private

  def ocr
    return unless attachment
    key = "waste_paper.#{SecureRandom.uuid}" 
    File.open(key, 'w+b') do |f|
      f.write attachment.body.decoded 
    end
    self.content = `tesseract #{key} -`.split("\n").map(&:strip).join("\n")
  ensure
    (File.delete(key) rescue nil) if defined?(key)
  end
end
