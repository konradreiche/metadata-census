module Util::Network

  # Helper to create a human-readable response string.
  #
  def response_message(response)
    if response.return_code == :too_many_redirects
      'Too many redirects'
    elsif response.success?
      response.code
    elsif response.timed_out?
      'Timed out'
    elsif response.code == 0
      'Error: ' + response.return_message
    else
      response.code
    end
  end

end
