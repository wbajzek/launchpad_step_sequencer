require "launchpad_step_sequencer/version"
require "unimidi"

class LaunchpadStepSequencer
  ROWS = 8
  COLUMNS = 8

  CHANNEL_1_NOTE_ON = 144
  CHANNEL_1_NOTE_OFF = 128
  CHANNEL_2_NOTE_ON = 176
  CHANNEL_2_NOTE_OFF = 160

  LIGHT_OFFSET = 104

  MIN_VELOCITY = 0
  HIGHLIGHT_VELOCITY = 100
  MAX_VELOCITY = 127

  ROW_OFFSETS = [
    0, 16, 32, 48, 64, 80, 96, 112
  ]

  SCALE = [
    48, 50, 52, 53, 55, 57, 59, 60
  ].reverse # because LaunchPad orientation is top -> bottom

  attr_reader :current_step
  attr_reader :enabled_steps
  attr_reader :enabled_notes

  def self.run(tempo = 120.0)
    sequencer = LaunchpadStepSequencer.new
    sequencer.midi_output # prompt for output
    sequencer.start
    input_thread = Thread.new do
      sequencer.handle_input
    end
    while (1)
      sleep(60.0 / tempo)
      sequencer.advance
    end
  ensure
    sequencer.all_notes_off
    Thread.kill(input_thread) if input_thread
  end

  def initialize
    @current_step = -1 # will advance to 0 on start
    @steps = 8
    @enabled_steps = (0..@steps-1).to_a
    @enabled_notes = []
  end

  def start
    step_lights_on
    advance
  end

  def stop
    unlight_current_step
    stop_current_step_notes
  end

  def advance
    stop_current_step_notes
    unlight_current_step
    @current_step += 1
    @current_step = 0 if @current_step == @steps
    start_current_step_notes
    light_current_step
    light_notes
  end

  def handle_input
    with_loop do |msg|
      if msg[:data][2] == 0
        case msg[:data][0]
        when CHANNEL_1_NOTE_ON then note_button_pressed(msg[:data][1])
        when CHANNEL_2_NOTE_ON then \
          step_button_pressed(msg[:data][1] - LIGHT_OFFSET)
        end
      end
    end
  ensure
    steps.each do |step|
      launchpadOutput.puts(CHANNEL_2_NOTE_ON, 104 + step, 0)
    end
  end

  def step_lights_on
    @enabled_steps.each do |step|
      launchpad_output.puts(CHANNEL_2_NOTE_ON,
                            LIGHT_OFFSET + step,
                            MAX_VELOCITY)
    end
  end

  def light_notes
    @enabled_notes.compact.each do |note|
      light_note(note)
    end
  end

  def light_note(note)
    launchpad_output.puts(CHANNEL_1_NOTE_ON,
                          note,
                          MAX_VELOCITY)
  end

  def unlight_note(note)
    launchpad_output.puts(CHANNEL_1_NOTE_OFF,
                          note,
                          MIN_VELOCITY)
  end

  def light_current_step
    step_lights.each do |light|
      launchpad_output.puts(CHANNEL_1_NOTE_ON,
                            light,
                            HIGHLIGHT_VELOCITY)
    end
  end

  def unlight_current_step
    step_lights.each do |light|
      launchpad_output.puts(CHANNEL_1_NOTE_OFF,
                            light,
                            MIN_VELOCITY)
    end
  end

  def light_step_button(light)
    launchpad_output.puts(CHANNEL_2_NOTE_ON,
                          LIGHT_OFFSET + light,
                          MAX_VELOCITY)
  end

  def unlight_step_button(light)
    launchpad_output.puts(CHANNEL_2_NOTE_ON,
                          LIGHT_OFFSET + light,
                          MIN_VELOCITY)
  end

  def step_button_pressed(step)
    if @enabled_steps.include?(step)
      @enabled_steps.delete(step)
      unlight_step_button(step)
    else
      @enabled_steps.insert(step, step)
      light_step_button(step)
    end
  end

  def note_button_pressed(note)
    if @enabled_notes.include?(note)
      @enabled_notes.delete(note)
      unlight_note(note)
    else
      @enabled_notes.insert(note, note)
      light_note(note)
    end
  end

  def scale_note(note)
    SCALE[ROW_OFFSETS.index(note)]
  end

  def launchpad_input
    @launchpad_input ||=  UniMIDI::Input.all.select { |d| d.name.match /Launchpad/ }.first
  end

  def launchpad_output
    @launchpad_output ||= UniMIDI::Output.all.select { |d| d.name.match /Launchpad/ }.first
  end

  def midi_output
    @midi_output ||= UniMIDI::Output.gets
  end

  def all_notes_off
    for i in 0..127
      midi_output.puts(CHANNEL_1_NOTE_ON, i, MIN_VELOCITY)
      midi_output.puts(CHANNEL_1_NOTE_OFF, i, MIN_VELOCITY)
      launchpad_output.puts(CHANNEL_1_NOTE_ON, i, MIN_VELOCITY)
      launchpad_output.puts(CHANNEL_1_NOTE_OFF, i, MIN_VELOCITY)
      launchpad_output.puts(CHANNEL_2_NOTE_ON, i, MIN_VELOCITY)
      launchpad_output.puts(CHANNEL_2_NOTE_OFF, i, MIN_VELOCITY)
    end
  end

  private

  def start_current_step_notes
    current_step_notes do |offset|
      midi_output.puts(CHANNEL_1_NOTE_ON,
                       scale_note(offset),
                       MAX_VELOCITY)
    end
  end

  def current_step_notes
    ROW_OFFSETS.select { |offset|
      @enabled_notes.include?(offset + @current_step)
    }.each do |offset|
      yield offset
    end
  end

  def stop_current_step_notes
    current_step_notes do |offset|
      midi_output.puts(CHANNEL_1_NOTE_ON,
                       scale_note(offset),
                       MIN_VELOCITY)
      midi_output.puts(CHANNEL_1_NOTE_OFF,
                       scale_note(offset),
                       MIN_VELOCITY)
    end
  end

  def step_lights
    ROWS.times.collect { |row|
      ROW_OFFSETS[row] + current_step
    }
  end

  def with_loop(&block)
    while(1)
      launchpad_input.gets.each { |msg| yield msg }
    end
  end
end
