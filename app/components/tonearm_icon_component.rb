class TonearmIconComponent < ViewComponent::Base
  def initialize(current_page: "records")
    @current_page = current_page
    super
  end

  private

  def rotation_angle
    case @current_page
    when "records"
      0
    when "artists"
      15
    when "genres"
      30
    else
      0
    end
  end
end
