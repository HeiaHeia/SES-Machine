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
# end
#
# SesMachine::Hooks.send :extend, SesMachineHooks


module SesMachineAuthHooks
  private

  def ses_machine_authorize!
    true
  end
end

SesMachineController.send :include, SesMachineAuthHooks

