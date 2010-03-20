class Buildr::Project
  def leaf_project_name
    if self.parent
      return self.name[self.parent.name.size + 1, self.name.length]
    else
      return self.name
    end
  end
end