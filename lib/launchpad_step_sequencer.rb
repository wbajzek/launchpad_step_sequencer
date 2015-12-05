require "launchpad_step_sequencer/version"

class LaunchpadStepSequencer
  attr_reader :current_step
  attr_reader :enabled_steps
  attr_reader :enabled_notes

  def initialize
    @current_step = 0
    @steps = 8
    @enabled_steps = (0..@steps-1).to_a
    @enabled_notes = []
  end

  def advance
    @current_step += 1
    @current_step = 0 if @current_step == @steps
  end

  def step_button_pressed(step)
    if @enabled_steps.include?(step)
      @enabled_steps.delete(step)
    else
      @enabled_steps.push(step)
    end
  end

  def note_button_pressed(note)
    if @enabled_notes.include?(note)
      @enabled_notes.delete(note)
    else
      @enabled_notes.push(note)
    end
  end
end
