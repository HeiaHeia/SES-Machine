module SesMachineAuthHooks
  protected

  def ses_machine_authorize!
    true
  end
end

# module SesMachineHooks
#   def soft_bounce_hook(email)
#     # Add your code
#   end
#
#   def hard_bounce_hook(email)
#     # Add your code
#   end
#
#   def unknown_hook(email)
#     # Add your code
#   end
#
#   def spam_complaint_hook(email)
#     # Add your code
#   end
#
#   def auto_responder_hook(email)
#     # Add your code
#   end
# end

# SesMachine::Hooks.send :extend, SesMachineHooks
