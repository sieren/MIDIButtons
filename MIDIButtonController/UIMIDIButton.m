//
//  UIMIDIButton.m
//  Circula
//
//  Created by Matthias Frick on 16.06.2015.
//  Copyright (c) 2015 Matthias Frick. All rights reserved.
//

#import "UIMIDIButton.h"
#import "MIDIController.h"

@interface UIMIDIButton()
{
  int midiCtrlNumber;
  BOOL isInLearnMode;
}
@end

@implementation UIMIDIButton

-(void)setImage:(UIImage *)image forState:(UIControlState)state
{
  [super setImage:image forState:state];
  [self initMIDIwithReference:image.debugDescription]; // not best practice
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
  [super setTitle:title forState:state];
  [self initMIDIwithReference:title];
}

-(void)initMIDIwithReference:(NSString*)title
{
  isInLearnMode = false;
  midiCtrlNumber = (int)[[NSUserDefaults standardUserDefaults] integerForKey:title];

  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

  [center addObserverForName:@"MIDI Note"
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification *notif)
  {
     // this is the structure that we want to extract from the notification
     MIDIMessage info;

     // extract the NSData object from the userInfo dictionary using key "ImportantInformation"
     NSData *data = notif.userInfo[@"MIDI Note"];

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
  // actual button triggering gesture.
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(learnMidi:)];
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
        [[NSUserDefaults standardUserDefaults] setInteger:[[[alertView textFieldAtIndex:0] text] intValue] forKey:self.titleLabel.text];
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
      midiCtrlNumber = message.value;
      [[NSUserDefaults standardUserDefaults] setInteger:message.cc forKey:self.titleLabel.text];
      [[NSUserDefaults standardUserDefaults] synchronize];
      isInLearnMode = false;
    });
  }
  if (message.value == midiCtrlNumber) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (message.cc == 144)
      {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self setNeedsDisplay];
      }
    });
  }
}

@end
