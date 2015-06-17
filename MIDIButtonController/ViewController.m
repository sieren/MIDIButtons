//
//  ViewController.m
//  MIDIButtonController
//
//  Created by Matthias Frick on 17.06.2015.
//  Copyright (c) 2015 Matthias Frick. All rights reserved.
//

#import "ViewController.h"
#import "UIMIDIButton.h"
#import "MIDIController.h"
#import "UIMIDISlider.h"

@interface ViewController ()
{
  MIDIController *midiController;
}

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  midiController = [[MIDIController alloc] init];
  [self.view setBackgroundColor:[UIColor grayColor]];
  
  /*----- BUTTON EXAMLE ------*/
  UIMIDIButton *button = [[UIMIDIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, 50, 150, 80)];
  [button setTitle:@"TEST 1" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(testOneButtonFound:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  /*----- SLIDER EXAMLE ------*/
  UIMIDISlider *slider = [[UIMIDISlider alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, 80, 150, 80)];
  [slider setTitle:@"TEST 1" forState:UIControlStateNormal]; // for coherence, title is used as a tag
  [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:slider];
}

-(void)testOneButtonFound:(id)sender {
  UIMIDIButton *btn = (UIMIDIButton*)sender;
  btn.backgroundColor = btn.backgroundColor == [UIColor clearColor] ?
    [UIColor greenColor] : [UIColor clearColor];
  // Call Button Changes from here
}

-(void)sliderValueChanged:(id)sender {
  UIMIDISlider* sldr = (UIMIDISlider*) sender;
  // Process Slider Value
  NSLog(@"Slider Changed to: %g", sldr.value);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
