# MIDIButtons
A little example on how to easily make (UIKit's) Buttons and Sliders MIDI controllable.

The UI elements register to NSNotificationCenter to receive either control messages with values or note on/off depending on whether it is a button or a slider. You can register a target in your main view controller to further process the incoming information.

You can assign gesture recognizers to trigger an UIAlertView where the users can either enter a CC/Note manually or use the Learn Mode to automatically save the CC/Note of the next incoming message to the button.

This project partly relies on [PGMIDI](https://github.com/petegoodliffe/PGMidi) for the lower level MIDI work.

Parts of this code have been used for [Circula](https://www.facebook.com/circulaapp).