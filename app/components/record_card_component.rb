class RecordCardComponent < ViewComponent::Base
  def initialize(record:)
    @record = record
  end

  def missing_cover?
    !@record.cover_image.attached?
  end

  private

  attr_reader :record
end
