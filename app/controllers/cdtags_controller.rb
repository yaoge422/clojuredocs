# Error message on generate:
# The name 'TagsHelper' is either already used in your application or reserved by Ruby on Rails.
# hence the ugly name

class CdtagsController < ApplicationController
  def lookup
    q = params[:term]
    
    if not q
      render :json => []
      return
    end
    
    name = q + "%"
    
    @tags = Tag.find(:all, :conditions => ['name like ?', name]).
      sort{|a,b| Levenshtein.distance(q, a.name) <=> Levenshtein.distance(q, b.name)}.
      uniq
 
    render :json => @tags.map{|t| t.attributes}
  end
  
  def add
    
    @function = Function.find_by_id(params[:var_id])
    
    render json_fail "Couldn't find the var you wanted to tag with #{tag_name}." and return unless @function
    render json_fail "Must be logged in to add tags." and return unless current_user_session
    
    tag_name = params[:tag_name]
    
    if @function.all_tags_list.index(tag_name)
      render json_fail "#{@function.name} is already tagged with #{tag_name}." and return
    end
    
    current_user.tag(@function, :with => (@function.tags_from(current_user) << tag_name).join(","), :on => :tags)
    
    tag = Tag.find_by_name(tag_name)
    
    render :json => {
      :success => true, 
      :tag => tag.attributes
    }
    
  end
end
