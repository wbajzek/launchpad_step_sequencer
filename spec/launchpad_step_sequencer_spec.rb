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
end
