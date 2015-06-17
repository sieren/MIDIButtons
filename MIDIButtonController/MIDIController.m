//
//  MIDIController.m
//  Multitude
//
//  Created by Matthias Frick on 10.05.2015.
//  Copyright (c) 2015 Matthias Frick. All rights reserved.
//

#import "MIDIController.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

id thisClass;
@interface MIDIController() {
  MIDIClientRef   theMidiClient;
  MIDIEndpointRef midiOut;
  MIDIEndpointRef midiIn;
  MIDIPortRef     outPort;
  MIDIPortRef     inPort;
  Float64 intervalInNanoseconds;
  double tickDelta;
  uint64_t previousTime;
}
- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList;
@end

@implementation MIDIController

-(id)init {
  self = [super init];

  self = [super init];
  midi                            = [[PGMidi alloc] init];
  midi.networkEnabled             = YES;
  midi.virtualDestinationEnabled  = YES;
  midi.virtualSourceEnabled       = YES;
  midi.delegate                   = self;
  [self attachToAllExistingSources];

  NSLog(@"Initialized MIDI Controller");
  thisClass                       =self;
  MIDIClientCreate(CFSTR("MIDI Controller"), NULL, NULL,
                   &theMidiClient);

  MIDIDestinationCreate(theMidiClient, CFSTR("MIDI Controller"), ReadProc,  (__bridge void *)self, &midiIn);
  return self;
}

-(void)setDelegate:(id)newDelegate {
  delegate = newDelegate;
}

void ReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
  [thisClass midiSource:nil midiReceived:packetList];
}

- (void) attachToAllExistingSources
{
  for (PGMidiSource *source in midi.sources)
  {
    [source addDelegate:self];
  }
}

- (void) addString:(NSString*)string
{
  NSLog(@"%@", string);
}

NSString *ToString(PGMidiConnection *connection)
{
  return [NSString stringWithFormat:@"< PGMidiConnection: name=%@  >",
          connection.name];
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
  [source addDelegate:self];
  [self addString:[NSString stringWithFormat:@"Source added: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
  [self addString:[NSString stringWithFormat:@"Source removed: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
  [self addString:[NSString stringWithFormat:@"Desintation added: %@", ToString(destination)]];
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
  [self addString:[NSString stringWithFormat:@"Desintation removed: %@", ToString(destination)]];
}

- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
  MIDIPacket *packet = (MIDIPacket*)&packetList->packet[0];
  for (int i = 0; i < packetList->numPackets; ++i)
  {
    int statusByte = packet->data[0];
    
    if (statusByte >= 0xb0 && statusByte <= 0xd0)
    {
      MIDIMessage message = { packet->data[1], packet->data[2] };
      NSData *data = [NSData dataWithBytes:&message length:sizeof(MIDIMessage)];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"MIDI Message" object:self userInfo:@{ @"MIDI Message" : data }];
    }
    else
    {
      MIDIMessage message = { packet->data[0], packet->data[1] };
      NSData *data = [NSData dataWithBytes:&message length:sizeof(MIDIMessage)];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"MIDI Note" object:self userInfo:@{ @"MIDI Note" : data }];
    }
    packet = MIDIPacketNext(packet);
  }
}


@end
