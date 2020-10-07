#import "MidiController.h"
#import <CoreMIDI/CoreMIDI.h>
#import <AudioToolbox/AudioToolbox.h>
#define Midi_ONOff_Count_Limit  6

typedef enum {
    MIDI_RUNNING,
    MIDI_STOPPED

}Controller_State;

static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon);
void MyMIDINotifyProc (const MIDINotification  *message, void *refCon);
@interface MidiController ()
{
    int inorout;
    MIDIPortRef inPort ;
    MIDIPortRef outPort ;
    MIDIClientRef client;
    BOOL  ispaused;
    int oncount;
    int offcount;
    //Controller_State  currentstate;
}

@end
@implementation MidiController

-(void)setup
{
    _date=[NSDate date];

    _midiinhale=61;
    _midiexhale=73;
    _currentdirection=_midiexhale;
    _velocity=0;
    _previousVelocity=0;
    _speed=0;
    _duration=0.0;
    //_zerocount=0;
    _midiIsOn=false;
    //currentstate=MIDI_STOPPED;
      //  [self pause];
    _toggleIsON=NO;
    [self setupMIDI];
}

-(void)pause
{
    ispaused=YES;
}

-(void)resume
{
    ispaused=NO;
}

#pragma mark - midi
-(void) setupMIDI {
   // [_delegate sendLogToOutput:@"Midi setup"];

    client = NULL;
	MIDIClientCreate(CFSTR("Midi Client"), MyMIDINotifyProc,(__bridge void*) self, &client);
	
    inPort = NULL;
    outPort = NULL;
    
	MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc,(__bridge void*)  self, &inPort);
	MIDIOutputPortCreate(client, (CFStringRef)@"Output Port", &outPort);
	unsigned long sourceCount = MIDIGetNumberOfSources();
    [self setNumberOfSources:sourceCount];
   // [super automaticallyNotifiesObserversForKey:@"numberOfSources"];
	for (int i = 0; i < sourceCount; ++i) {
		MIDIEndpointRef src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		OSStatus nameErr = MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName);
		if (noErr == nameErr) {
		}
		MIDIPortConnectSource(inPort, src, NULL);
	}	
}

-(void)reset
{

}

-(BOOL)allowBreath
{
    if (_toggleIsON) {
        if (_currentdirection!=_midiexhale) {
            return NO;
        }
    }else if (!_toggleIsON)
    {
        
        if (_currentdirection!=_midiinhale) {
            return NO;
        }
    }
    return YES;
}

-(void)midiNoteBegan:(int)direction vel:(int)pvelocity{
    //[_delegate sendLogToOutput:[NSString stringWithFormat:@"is paysed  at stop%i",ispaused]];
    self.previousVelocity=self.velocity;

    _currentdirection=direction;
  
    if (![self allowBreath]) {
        return;
    }
       
   if (ispaused) {
        return;
    }
    _date=[NSDate date];
    [_delegate midiNoteBegan:self];
}

-(void)continueMidiNote:(int)pvelocity
{
    if (![self allowBreath]) {
        return;
    }
    
    if (ispaused) {
        return;
    }

    if (pvelocity!=127&&pvelocity!=0) {
        self.velocity=pvelocity;
        NSDate *adate=[NSDate date];
        self.duration=[adate timeIntervalSinceDate:self.date];
        // if (self.velocity>self.previousVelocity) {
        self.speed= (fabs(self.velocity-self.previousVelocity));
        self.previousVelocity=self.velocity;
        // self.speed=self.speed*10;
        
        if (self.previousVelocity!=0) {
            // self.previousVelocity=self.velocity;
        }
    }
  //}
    if (self.velocity!=127) {
        [_delegate midiNoteContinuing:self];
    }
}

-(void)stopMidiNote
{
    NSLog(@"Maybe remove");
    //if (_midiIsOn) {
    //[_delegate sendLogToOutput:[NSString stringWithFormat:@"is paysed  at stop%i",ispaused]];

    if (ispaused) {
        return;
       // [_delegate sendLogToOutput:[NSString stringWithFormat:@"paused%i",ispaused]];
    }
    _midiIsOn=NO;
    self.velocity=0.0;
    self.previousVelocity=0.0;
    self.speed=0.0;
    self.duration=0.0;
    [_delegate midiNoteStopped:self];
}

#pragma mark MIDI Output

-(void)sendValue:(int)note onoff:(int)onoff
{
    /**const UInt8 noteOn[]  = { 0x90, note, 127 };
     const UInt8 noteOff[] = { 0x80, note, 0   };
    [_delegate sendLogToOutput:@"got this 127"];
    [self sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:0.1];
     [self sendBytes:noteOff size:sizeof(noteOff)];**/
    const UInt8 noteOn[]  = { 0x90, note, 127 };
    // const UInt8 noteOff[] = { 0x80, note, 0   };
    [self sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:0.1];
    // [self sendBytes:noteOff size:sizeof(noteOff)];
}

- (void) sendPacketList:(const MIDIPacketList *)packetList
{
    for (ItemCount index = 0; index < MIDIGetNumberOfDestinations(); ++index)
    {
        MIDIEndpointRef outputEndpoint = MIDIGetDestination(index);
        if (outputEndpoint)
        {
            // Send it
            MIDISend(outPort, outputEndpoint, packetList);
            // NSLogError(s, @"Sending MIDI");
        }
    }
}

- (void) sendBytes:(const UInt8*)data size:(UInt32)size
{
    // NSLog(@"%s(%u bytes to core MIDI)", __func__, unsigned(size));
    assert(size < 65536);
    Byte packetBuffer[size+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, size, data);
    [self sendPacketList:packetList];
}

static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
	MidiController *vc = (__bridge MidiController*) refCon;
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	int midiCommand = packet->data[0] >> 4;
    int note = packet->data[1] & 0x7F;
    int veolocity = packet->data[2] & 0x7F;

    if (midiCommand == 0x09) {
        vc.midiIsOn=YES;
       // [vc.delegate sendLogToOutput:[NSString stringWithFormat:@"Command =%d ,Note=%d, Velocity=%d",midiCommand, note, veolocity]];
        [vc midiNoteBegan:note vel:veolocity];
    }
    
    if (midiCommand==11) {
        if (note==2) {
                [vc continueMidiNote:veolocity];
        }else
        {
            //ended
            [vc stopMidiNote];
        }
    }
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
	MidiController *vc = (__bridge MidiController*) refCon;
    /** [vc appendToTextView:[NSString stringWithFormat:
     @"MIDI Notify, messageId=%ld,", message->messageID]];**/
    
    [vc.delegate sendLogToOutput:[NSString stringWithFormat:
                                  @"MIDI Notify, messageId=%ld,", message->messageID]];
}
@end
