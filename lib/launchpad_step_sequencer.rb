require "launchpad_step_sequencer/version"

class LaunchpadStepSequencer
  ROWS = 8
  COLUMNS = 8

  CHANNEL_1_NOTE_ON = 144
  CHANNEL_1_NOTE_OFF = 128
  CHANNEL_2_NOTE_ON = 176
  CHANNEL_2_NOTE_OFF = 160

  LIGHT_OFFSET = 104

  MIN_VELOCITY = 0
  MAX_VELOCITY = 127

  COLUMN_OFFSETS = [
    0, 16, 32, 48, 64, 80, 96, 112
  ]

  attr_reader :current_step
  attr_reader :enabled_steps
  attr_reader :enabled_notes

  def initialize
    @current_step = -1 # will advance to 0 on start
    @steps = 8
    @enabled_steps = (0..@steps-1).to_a
    @enabled_notes = []
    step_lights_on
    light_current_step
  end

  def step_lights_on
    @enabled_steps.each do |step|
      launchpad_output.puts(CHANNEL_2_NOTE_ON,
                            LIGHT_OFFSET + step,
                            MAX_VELOCITY)
    end
  end

  def light_current_step
    ROWS.times do |row|
      launchpad_output.puts(CHANNEL_2_NOTE_ON,
                            COLUMN_OFFSETS[current_step] + row,
                            MAX_VELOCITY)
    end
  end

  def unlight_current_step
    ROWS.times do |row|
      launchpad_output.puts(CHANNEL_2_NOTE_ON,
                            COLUMN_OFFSETS[current_step] + row,
                            MIN_VELOCITY)
    end
  end

  def start
    advance
  end

  def stop
    unlight_current_step
  end

  def advance
    stop_current_step_notes
    unlight_current_step
    @current_step += 1
    @current_step = 0 if @current_step == @steps
    start_current_step_notes
    light_current_step
  end

  def start_current_step_notes
    midi_output.puts(CHANNEL_1_NOTE_ON,
                     2,
                     MAX_VELOCITY)
  end

  def stop_current_step_notes
    midi_output.puts(CHANNEL_1_NOTE_ON,
                     2,
                     MIN_VELOCITY)
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

  def launchpad_output
    @launchpad_output ||= StringIO.new
  end

  def midi_output
    @midi_output ||= StringIO.new
  end
end
