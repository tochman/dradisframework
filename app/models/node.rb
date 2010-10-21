# Dradis Note objects are associated with a Node. It is possible to create a 
# tree structure of Nodes to hierarchically structure the information held
# in the repository.
# 
# Each Node has a :parent node and a :label. Nodes can also have many 
# Attachment objects associated with them.
class Node < ActiveRecord::Base
  acts_as_tree
  has_many :notes

  validates_presence_of :label
  validates_format_of :label, :with => /^[A-Za-z\d_]+$/, :message => "can only be alphanumeric with no spaces"


  # Return the JSON structure representing this Node and any child nodes
  # associated with it.
  def as_json(options={})
    json = { :text => self.label, :id => self.attributes['id'] }
    if (self.children.any?)
      json[:children] = self.children
    end
    return json
  end

  # Return all the Attachment objects associated with this Node.
  def attachments
    Attachment.find(:all, :conditions => {:node_id => self.id})
  end
end
