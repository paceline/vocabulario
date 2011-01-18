class Status < Hash
  
  # Timeline with all actions
  def self.timeline(user_id = nil, since = DateTime.now-30)
    timeline = []
    user = User.find_by_id_or_permalink(user_id) if user_id
    ['comments','lists','scores','vocabularies'].each do |entity|
      timeline += if user
          user.send(entity).send("find", :all, :conditions => ['created_at >= ?', since], :order => 'created_at DESC').collect { |item| item.updates_for_timeline }
        else
          Object.const_get(entity.camelcase.singularize).find(:all, :conditions => ['created_at >= ?', since], :order => 'created_at DESC').collect { |item| item.updates_for_timeline }
        end
    end
    timeline.sort { |x,y| y[:created_at] <=> x[:created_at] }
  end
  
  # ID used in feeds
  def id
    "#{self[:user][:id]}#{self[:id]}".to_i
  end

end