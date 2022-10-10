class LocationsSelectInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      label_html <<
      content_html
    end
  end

  private

  def content_html
    builder.template.content_tag(:div, id: 'locations_admin_select', class: 'locations-input') do
      cities_select <<
      locations_select <<
      locations_list <<
      hidden_field_for_ids
    end
  end

  def cities_select
    builder.template.select_tag(
      'cities_select',
      builder.template.options_from_collection_for_select(City.all, 'id', 'name'),
      include_blank: true
    )
  end

  def locations_select
    builder.template.content_tag(
      :select,
      '',
      id: 'locations_select',
      data: Location.select(:id, :city_id, :name).where.not(city_id: nil).to_a
        .group_by(&:city_id).map do |city_id, locations|
          ["city_#{city_id}", locations]
        end.to_h
    )
  end

  def hidden_field_for_ids
    builder.template.content_tag(:div, id: 'locations_hidden_fields') do
      object.send(method).each.map do |location|
        builder.template.hidden_field_tag(
          "#{object.class.to_s.underscore}[location_ids][]",
          location.id,
          data: {
            location_id: location.id
          }
        )
      end.join.html_safe
    end
  end
  
  def locations_list
    builder.template.content_tag(:ul, id: 'locations_list') do
      object.send(method).map do |location|
        builder.template.content_tag(:li) do
          builder.template.content_tag(:a, '×', href: '#', data: {
            location_id: location.id
          }) << location.name
        end
      end.join.html_safe
    end
  end
end
