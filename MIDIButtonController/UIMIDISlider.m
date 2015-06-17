//
//  UIMIDISlider.m
//  MIDIButtonController
//
//  Created by Matthias Frick on 17.06.2015.
//  Copyright (c) 2015 Matthias Frick. All rights reserved.
//

#import "UIMIDISlider.h"
#import "MIDIController.h"

@interface UIMIDISlider()
{
  int midiCtrlNumber;
  BOOL isInLearnMode;
  NSString *tag;
}
@end
@implementation UIMIDISlider

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
  tag = title;
  [self initMIDIwithReference:title];
}

-(void)initMIDIwithReference:(NSString*)title
{
  isInLearnMode = false;
  midiCtrlNumber = (int)[[NSUserDefaults standardUserDefaults] integerForKey:title];

  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

  [center addObserverForName:@"MIDI Message"
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *notif)
   {
     // this is the structure that we want to extract from the notification
     MIDIMessage info;

     // extract the NSData object from the userInfo dictionary using key "ImportantInformation"
     NSData *data = notif.userInfo[@"MIDI Message"];

     // do some sanity checking
     if ( !data || data.length != sizeof(info) )
     {
       NSLog( @"Well, that didn't work" );
     }
     else
     {
       // finally, extract the structure from the NSData object
       [data getBytes:&info length:sizeof(info)];
       [self processMIDIMessage:info];
     }
   }];

  // Using Long Press to start Learn Mode,
  // can be changed into other recognizers
  // just make sure it doesnt interfere with the
  // actual triggering gesture.
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(learnMidi:)];
  longPress.numberOfTouchesRequired = 2;
  [self addGestureRecognizer:longPress];
}

-(void)learnMidi:(UILongPressGestureRecognizer *)sender {
  if (sender.state == UIGestureRecognizerStateBegan)
  {
    if (midiCtrlNumber == 0) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MIDI"
                                                      message:@"Assign a MIDI CC to the knob by either leaving it blank and turning a knob or entering a CC Number manually."
                                                     delegate:self
                                            cancelButtonTitle:@"CANCEL"
                                            otherButtonTitles:@"LEARN", nil];
      alert.alertViewStyle = UIAlertViewStylePlainTextInput;
      [alert show];
    }
    else
    {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MIDI"
                                                      message:[NSString stringWithFormat:@"Forget MIDI CC: %i ?", midiCtrlNumber]
                                                     delegate:self
                                            cancelButtonTitle:@"CANCEL"
                                            otherButtonTitles:@"RELEARN", @"FORGET", nil];
      alert.alertViewStyle = UIAlertViewStylePlainTextInput;
      [alert show];
    }
  }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      midiCtrlNumber = 0;
      if ([[[alertView textFieldAtIndex:0] text] intValue])
      {
        midiCtrlNumber = [[[alertView textFieldAtIndex:0] text] intValue];
        [[NSUserDefaults standardUserDefaults] setInteger:[[[alertView textFieldAtIndex:0] text] intValue] forKey:tag];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
      else
      {
        midiCtrlNumber = 0;
        isInLearnMode = true;
      }
      break;
    case 2:
      midiCtrlNumber = 0;
  }
}

-(void)processMIDIMessage:(MIDIMessage) message {
  if (isInLearnMode) {
    dispatch_async(dispatch_get_main_queue(), ^{
      midiCtrlNumber = message.cc;
      [[NSUserDefaults standardUserDefaults] setInteger:message.cc forKey:tag];
      [[NSUserDefaults standardUserDefaults] synchronize];
      isInLearnMode = false;
    });
  }
  if (message.cc == midiCtrlNumber) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.value = (float)message.value / 127;
      [self sendActionsForControlEvents:UIControlEventValueChanged];
      [self setNeedsDisplay];
      // do work here
    });
  }
}

@end
