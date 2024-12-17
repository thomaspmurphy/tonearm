module RecordsHelper
  def format_badge_color(format)
    case format
    when 'vinyl'
      'bg-purple-600 text-white'
    when 'cassette'
      'bg-yellow-600 text-white'
    when 'cd'
      'bg-blue-600 text-white'
    else
      'bg-gray-600 text-white'
    end
  end
end
