namespace :awesome_set do
    desc "Rebuild Category index"
    task category_rebuild: :environment do
        Category.rebuild!
    end
end