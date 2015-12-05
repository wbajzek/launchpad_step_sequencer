require "launchpad_step_sequencer/version"

class LaunchpadStepSequencer
  attr_reader :current_step

  def initialize
    @current_step = 0
    @steps = 8
  end

  def advance
    @current_step += 1
    @current_step = 0 if @current_step == @steps
  end
end
