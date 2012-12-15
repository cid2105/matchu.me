class AddFbFriends
  @queue = :add_fb_friends

  def self.perform(user_id, token)
  	@facebook = Koala::Facebook::API.new(token)
  	friends_hash = Hash.new
 
    @facebook.get_connections("me", "friends", :fields => "name, email, id, education").each do |hash|
      if hash.has_key? 'education' and hash['education'].length > 1 and hash['education'][1].has_key? 'school' and hash['education'][1]['school'].has_key? 'name' and  hash['education'][1]['school']['name'] == "Columbia University"
        User.find_or_create_by_name_and_uid(name: hash['name'], uid: hash['id'] )
        friends_hash[hash['name']] = hash['id']
      end
    end

    User.find(user_id).update_attributes(friends: friends_hash)
  end
end

