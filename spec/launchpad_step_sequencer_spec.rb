require 'spec_helper'

describe LaunchpadStepSequencer do
  subject { described_class.new }

  it 'has a version number' do
    expect(LaunchpadStepSequencer::VERSION).not_to be nil
  end

  context 'when started' do
    xit 'starts on the first step' do
    end

    xit 'turns on the step number lights' do
    end

    xit 'highlights the first step number light' do
    end

    xit 'starts any selected notes' do
    end

    context 'when advanced' do
      xit 'unhighlights the first step number light' do
      end

      xit 'highlights the second step number light' do
      end

      xit 'stops any unselected notes' do
      end

      context 'from the last step' do
        xit 'returns to the first step' do
        end
      end
    end

    context 'when stopped' do
      xit 'unhighlights the current step number light' do
      end
    end
  end

  context 'when a note button is pressed' do
    context 'when that note is disabled' do
      xit 'enables the note' do
      end
    end

    context 'when that note is enabled' do
      xit 'disables the note' do
      end
    end
  end

  context 'when a step button is pressed' do
    context 'when that step is enabled' do
      xit 'disables the step' do
      end
    end

    context 'when that step is disabled' do
      xit 'enables the step' do
      end
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
