class Status < Hash

  # ID used in feeds
  def id
    "#{self[:user][:id]}#{self[:id]}".to_i
  end

end