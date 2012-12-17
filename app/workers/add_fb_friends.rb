class AddFbFriends
  @queue = :add_fb_friends

  def self.perform(user_id, token)
  	@facebook = Koala::Facebook::API.new(token)
  	friends_hash = Hash.new
 
    @facebook.get_connections("me", "friends", :fields => "name, email, id, education").each do |hash|
      if hash.has_key? 'education' and hash['education'].length > 1 and hash['education'][1].has_key? 'school' and hash['education'][1]['school'].has_key? 'name' and  ( hash['education'][1]['school']['name'] == "Columbia University" or hash['education'][1]['school']['name'].downcase.split.include? "barnard" )
        college = hash['education'][1]
        major = (college.has_key? 'concentration')? college['concentration'].map {|c| c['name']}.join(' ') : nil        
        year = (college.has_key?('year')) ? college['year']['name'] : nil
        next if not year.nil? and year.to_i < 2011
        school =  hash['education'][1]['school']['name']
        index = rand(User.count)
        
        unless User.exists?(uid: hash['id'])
          User.create(name: hash['name'], uid: hash['id'], school: school, major: major, year: year, index: index)
        end

        friends_hash[hash['name']] = hash['id']
      end
    end

    User.find(user_id).update_attributes(friends: friends_hash)
  end
end

