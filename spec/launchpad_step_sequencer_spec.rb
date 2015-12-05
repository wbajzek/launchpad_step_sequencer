require 'spec_helper'

describe LaunchpadStepSequencer do
  subject { described_class.new }

  it 'has a version number' do
    expect(LaunchpadStepSequencer::VERSION).not_to be nil
  end

  context 'when started' do
    let(:initial_step) { 0 }

    it 'starts on the first step' do
      expect(subject.current_step).to eq(initial_step)
    end

    xit 'turns on the step number lights' do
    end

    xit 'highlights the first step number light' do
    end

    xit 'starts any selected notes' do
    end

    context 'when advanced' do
      before do
        subject.advance
      end

      it 'moves to the next step' do
        expect(subject.current_step).to eq(initial_step + 1)
      end

      xit 'unhighlights the first step number light' do
      end

      xit 'highlights the second step number light' do
      end

      xit 'stops any unselected notes' do
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
      xit 'unhighlights the current step number light' do
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
    end

    context 'when that step is disabled' do
      before do
        subject.step_button_pressed(step) # again
      end

      it 'enables the step' do
        expect(subject.enabled_steps).to include(step)
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
