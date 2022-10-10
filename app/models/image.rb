class Image < ApplicationRecord
  belongs_to :record, optional: true, polymorphic: true
  has_attached_file :photo, styles: { large: '1000x1000', medium: '500x500>', icon: '100x100>' }, default_url: 'https://api.elgrocer.com/images/:style/missing.png'
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  validate :validate_image_size

  def photo_url(size = 'medium')
    photo ? photo.url(size) : nil
  end

  def validate_image_size
    errors.add(:photo, 'Photo file size must be under 2mbs') if photo.present? and photo.size > 2.megabytes
  end
end
