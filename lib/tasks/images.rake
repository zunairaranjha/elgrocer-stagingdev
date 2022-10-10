namespace :images do
    desc "Uploads product image from external url"
    task upload: :environment do
        products = Product.where("photo_file_size IS NULL AND image_external_url IS NOT NULL").all

        products.each do |prod|
            prod.photo = open(prod.image_external_url) rescue nil
            prod.save
        end
    end
end