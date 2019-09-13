class TypedTarget < Target
  default_scope { where("type = '"+Target::TYPED_TARGET+"'") }
end
