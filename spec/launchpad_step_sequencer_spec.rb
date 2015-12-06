require 'spec_helper'

describe LaunchpadStepSequencer do
  subject { described_class.new }
  let(:midi_message) { "%i\n%i\n%i\n" }
  let(:launchpad_midi) { StringIO.new }
  let(:midi) { StringIO.new }

  before do
    allow(subject).to receive(:launchpad_output). \
      and_return( launchpad_midi )
    allow(subject).to receive(:midi_output). \
      and_return( midi )
  end

  it 'has a version number' do
    expect(LaunchpadStepSequencer::VERSION).not_to be nil
  end

  context 'when started' do
    let(:initial_step) { 0 }
    let(:note) { 0 }

    before do
      subject.note_button_pressed(note)
      subject.start
    end

    it 'turns on the step number lights' do
      expect(subject.launchpad_output.string).to match(
        subject.enabled_steps.collect { |step|
          midi_message % [
            described_class::CHANNEL_2_NOTE_ON,
            described_class::LIGHT_OFFSET + step,
            described_class::MAX_VELOCITY
          ]
        }.join
      )
    end

    it 'starts on the first step' do
      expect(subject.current_step).to eq(initial_step)
    end

    it 'turns on the first step lights' do
      expect(subject.launchpad_output.string).to match(
        (0..7).to_a.collect { |row|
          midi_message % [
            described_class::CHANNEL_1_NOTE_ON,
            described_class::ROW_OFFSETS[row],
            described_class::HIGHLIGHT_VELOCITY
          ]
        }.join
      )
    end

    it 'starts any selected notes' do
      expect(subject.midi_output.string).to match(
        midi_message % [
          described_class::CHANNEL_1_NOTE_ON,
          subject.scale_note(
            described_class::ROW_OFFSETS[initial_step]
          ),
          described_class::MAX_VELOCITY
        ]
      )
    end

    context 'when advanced' do
      let(:previous_column_light_offset) {
        described_class::ROW_OFFSETS[0]
      }

      let(:column_light_offset) {
        described_class::ROW_OFFSETS[1]
      }

      before do
        subject.advance
      end

      it 'moves to the next step' do
        expect(subject.current_step).to eq(initial_step + 1)
      end

      it 'unhighlights the first step number light' do
        expect(subject.launchpad_output.string).to match(
          (0..7).to_a.collect { |row|
            midi_message % [
              described_class::CHANNEL_1_NOTE_OFF,
              described_class::ROW_OFFSETS[row] - 1,
              described_class::MIN_VELOCITY
            ]
          }.join
        )
      end

      it 'highlights the second step number light' do
        expect(subject.launchpad_output.string).to match(
          (0..7).to_a.collect { |row|
            midi_message % [
              described_class::CHANNEL_1_NOTE_ON,
              described_class::ROW_OFFSETS[row],
              described_class::HIGHLIGHT_VELOCITY
            ]
          }.join
        )
      end

      it 'stops any unselected notes' do
        expect(subject.midi_output.string).to match(
          midi_message % [
            described_class::CHANNEL_1_NOTE_ON,
            subject.scale_note(
              described_class::ROW_OFFSETS[initial_step]
            ),
            described_class::MIN_VELOCITY
          ]
        )
      end

      context 'from the last step' do
        before do
          7.times do
            subject.advance
          end
        end

        it 'returns to the first step' do
          expect(subject.current_step).to eq(initial_step)
        end
      end
    end

    context 'when stopped' do
      before do
        subject.stop
      end

      it 'unhighlights the current step number light' do
        expect(subject.launchpad_output.string).to match(
          (0..7).to_a.collect { |row|
            midi_message % [
              described_class::CHANNEL_1_NOTE_OFF,
              described_class::ROW_OFFSETS[row] - 1,
              described_class::MIN_VELOCITY
            ]
          }.join
        )
      end

      it 'stops any current step notes' do
        expect(subject.midi_output.string).to match(
          midi_message % [
            described_class::CHANNEL_1_NOTE_ON,
            subject.scale_note(
              described_class::ROW_OFFSETS[initial_step]
            ),
            described_class::MIN_VELOCITY
          ]
        )
      end
    end
  end

  context 'when a note button is pressed' do
    let(:note) { 35 }

    before do
      subject.note_button_pressed(note)
    end

    context 'when that note is disabled' do
      it 'enables the note' do
        expect(subject.enabled_notes).to include(note)
      end
    end

    context 'when that note is enabled' do
      before do
        subject.note_button_pressed(note) #again
      end

      it 'disables the note' do
        expect(subject.enabled_notes).not_to include(note)
      end
    end
  end

  context 'when a step button is pressed' do
    let(:step) { 2 }

    before do
      subject.step_button_pressed(step)
    end

    context 'when that step is enabled' do
      it 'disables the step' do
        expect(subject.enabled_steps).not_to include(step)
      end

      it 'unlights the step light' do
        expect(subject.launchpad_output.string).to match(
          midi_message % [
            described_class::CHANNEL_2_NOTE_ON,
            described_class::LIGHT_OFFSET + step,
            described_class::MIN_VELOCITY
          ]
        )
      end
    end

    context 'when that step is disabled' do
      before do
        subject.step_button_pressed(step) # again
      end

      it 'enables the step' do
        expect(subject.enabled_steps).to include(step)
      end

      it 'lights the step light' do
        expect(subject.launchpad_output.string).to match(
          midi_message % [
            described_class::CHANNEL_2_NOTE_ON,
            described_class::LIGHT_OFFSET + step,
            described_class::MAX_VELOCITY
          ]
        )
      end
    end
  end

  context 'when the A button is pressed' do
    xit 'transposes up a half step' do
    end
  end

  context 'when the B button is pressed' do
    xit 'transposes down a half step' do
    end
  end

  context 'when the C button is pressed' do
    xit 'moves sequence up a scale degree' do
    end
  end

  context 'when the D button is pressed' do
    xit 'moves sequence down a scale degree' do
    end
  end

  context 'when the E button is pressed' do
    xit 'scrolls up' do
    end
  end

  context 'when the F button is pressed' do
    xit 'scrolls down' do
    end
  end

  context 'when the G button is pressed' do
    xit 'scrolls left' do
    end
  end

  context 'when the H button is pressed' do
    xit 'scrolls right' do
    end
  end
end
