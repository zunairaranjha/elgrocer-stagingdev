class Versions::CheckVersion < Versions::Base
  integer :client_type
  string :client_version

  def execute
    check_version
  end

  private

  def check_version
    version = client_version.split('.')

    update = Version.order(majorversion: :desc, minorversion: :desc, revision: :desc)
                               .where(
                                 '(majorversion > ? OR
                                  (majorversion = ? AND minorversion > ?) OR
                                  (majorversion = ? AND minorversion = ? AND revision > ?)) AND
                                  devise_type = ? AND
                                  action > 0',
                                 version[0],
                                 version[0], version[1],
                                 version[0], version[1], version[2],
                                 client_type
                               )
                               .first

    return { action: 0 } if update.nil?
    { action: update.action, message: update.message }
  end
end
