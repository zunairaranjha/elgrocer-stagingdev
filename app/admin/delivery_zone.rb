# frozen_string_literal: true

ActiveAdmin.register DeliveryZone do

  permit_params :kml, :name, :coordinates

  # remove_filter :retailer_delivery_zones
  # remove_filter :retailers

  index do
    column :name
    column :kml_file_name
    actions
  end


  show do |delivery_zone|
    attributes_table_for delivery_zone do
      [:name].each do |f|
        row f
      end
      row :map do
        """
          <script src='https://maps.googleapis.com/maps/api/js?key=AIzaSyBvJex_MXaq5D3UeM9vmfAMJ35mfct0jlA'></script>
          <div id='map' style='width: 100%; height: 300px;'></div>
          <script>
            function initialize(){
              google.maps.Polygon.prototype.getBounds = function() {
                var bounds = new google.maps.LatLngBounds();
                var paths = this.getPaths();
                var path;
                for (var i = 0; i < paths.getLength(); i++) {
                    path = paths.getAt(i);
                    for (var ii = 0; ii < path.getLength(); ii++) {
                        bounds.extend(path.getAt(ii));
                    }
                }
                return bounds;
              };
              var map = new google.maps.Map(document.getElementById('map'), {
                zoom: 12,
                center: {lat: 24.386, lng: 54.272},
                mapTypeId: google.maps.MapTypeId.TERRAIN
              });
              var polygonCoords = #{delivery_zone.coords_to_json};
              var deliveryZone = new google.maps.Polygon({
                paths: polygonCoords,
                strokeColor: '#FF0000',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#FF0000',
                fillOpacity: 0.35
              });
              map.fitBounds(deliveryZone.getBounds());
              deliveryZone.setMap(map);
            }
            google.maps.event.addDomListener(window, 'load', initialize);
          </script>
        """.html_safe
      end
    end
  end

  form do |f|
    f.inputs "KML file" do
      f.input :name
      f.input :kml, as: :file
    end
    f.actions
  end

  filter :retailer_id_includes,as: :string, label: 'Retailer ID'
  filter :name
  filter :description
  filter :color
  filter :width
  filter :created_at
  filter :updated_at
  filter :kml_file_name
  filter :kml_content_type
  filter :kml_file_size
  filter :kml_updated_at

  controller do
    def create
      merge_polygon
      create!
    end

    def update
      merge_polygon
      update!
    end

    private

    def merge_polygon
      if params[:delivery_zone][:kml].present?
        file = params['delivery_zone']['kml'].tempfile
        begin
          importer = DeliveryZone::ImporterService.new(file)
          params[:delivery_zone].merge!(coordinates: importer.polygon)
        rescue
          flash[:notice] = "not kml format!"
        end
      end
    end
  end
end
