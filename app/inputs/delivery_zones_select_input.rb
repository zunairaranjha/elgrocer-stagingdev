class DeliveryZonesSelectInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      label_html <<
      content_html
    end
  end

  private

  def content_html
    builder.template.content_tag(:div, id: 'delivery_zone_admin_select', class: 'delivery-zone-input') do
      delivery_zones_select <<
      delivery_zones_list <<
      hidden_field_for_ids
    end
  end

  def delivery_zones_select
    builder.template.select_tag(
      'delivery_zones_select',
      builder.template.options_from_collection_for_select(DeliveryZone.where.not(name: nil), 'id', 'name'),
      include_blank: true
    )
  end

  def hidden_field_for_ids
    builder.template.content_tag(:div, id: 'delivery_zones_hidden_fields') do
      object.send(method).each.map do |delivery_zone|
        builder.template.hidden_field_tag(
          "#{object.class.to_s.underscore}[delivery_zone_ids][]",
          delivery_zone.id,
          data: {
            delivery_zone_id: delivery_zone.id
          }
        )
      end.join.html_safe
    end
  end

  def delivery_zones_list
    builder.template.content_tag(:ul, id: 'delivery_zones_list') do
      object.delivery_zones.map do |location|
        builder.template.content_tag(:li) do
          builder.template.content_tag(:a, '×', href: '#', data: {
            delivery_zone_id: location.id
          }) << location.name
        end
      end.join.html_safe
    end
  end
end
