module SesMachineHelper
  
  def bounce_type(type)
    SesMachine::Bounce::TYPES.invert[type].to_s
  end
end
