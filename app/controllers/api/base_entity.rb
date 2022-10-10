# frozen_string_literal: true

module API
  # base class to parse json entity response
  class BaseEntity < Grape::Entity
    format_with(:string, &:to_s)
    format_with(:integer, &:to_i)
    format_with(:float, &:to_f)
    format_with(:bool) { |val| to_boolean(val) }
    format_with(:array, &:to_a)
    format_with(:dateTime) { |val| val&.utc&.iso8601.to_s }

    def to_boolean(str)
      ['true', true].include?(str)
    end
  end
end
