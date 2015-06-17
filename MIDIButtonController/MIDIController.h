//
//  MIDIController.h
//  Multitude
//
//  Created by Matthias Frick on 10.05.2015.
//  Copyright (c) 2015 Matthias Frick. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import "PGArc.h"

@interface MIDIController : NSObject <PGMidiDelegate, PGMidiSourceDelegate> {
id delegate;
PGMidi                    *midi;
}
-(void)setDelegate:(id)newDelegate;

@end

typedef struct {
  int cc;
  int value;
} MIDIMessage;

@interface NSObject(MIDIControllerDelegate)

@end