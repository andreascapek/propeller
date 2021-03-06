{{

┌──────────────────────────────────────────┐
│ dservo_use_6_Servos_Example         v1.0 │
│ Author: Diego Pontones                   │               
│ Copyright (c) 2010 Diego Pontones        │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

INTRODUCTION

The following object is an example on how to use the dServo object to control 6 servo motors (robotic arm example).

HISTORY
  v1.0  2010-03-24  Beta release
                          
}}   


CON
   
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier = 80 MHz  
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

  NumServos = 6                              ' Number of servos to control 1 to 14

  
VAR

  byte pin[NumServos]                        ' Propeller pin numbers for each servo. 
  long CurrPos[NumServos]                    ' Contains the current Pulse Width (Position) for each servo, -1000 to 1000 
  long NewPos[NumServos]                     ' Enter the desired New Pulse Width (Position) for each servo, -1000 to 1000 
  long NumPulses[NumServos]                  ' Number of Pulses to be sent for each servo. (pulse period is 20 ms, 50 ms = 1 sec)
  long GradMove                              ' One bit for each servo. If bit is set then movement will be gradual.
  long AccDecMove                            ' One bit for each servo. If bit is set then movement will have Acceleration/Deceleration. 
  long HoldPulse                             ' One bit for each servo. If bit is set then pulses will be sent continuously to hold the new position


OBJ

   servos : "dServo"                         ' Declare Servos object

PUB testServos  | index, startOK             ' Example for a Robotic Arm with 6 servos

  {{
  Robot Arm Example specific notes
  Servo 1: Base Rotate, positive is clockwise rotate, towards robot right
  Servo 2: Shoulder, 0 = 90 degrees up, positive towards the back, negative towards front
  Servo 3: Elbow, 0 is about 90 degrees, positive towards the back, negative towards front  
  Servo 4: Wrist, 0 is about perpendicular to arm, positive towards back, negative towards front, from 900 to -900
  Servo 5: Wrist Rotate, 100 is in line with arm, from 900 to -900
  Servo 6: Grip, from 300 close to -500 fully open
  }}

 
  repeat index from 0 to (NumServos - 1) 
        pin[index]   := lookupz(index: 15,14,13,11,10,9)  'Initialize value of propeller pins connected to each servo    
        NumPulses[index] := 0
  S6(70,0,-540,-410,0,0)  'Initialize initial positions for each servo.
                          'Note that a known arm storage position is used at the beginning and at the end in order to avoid
                          'a violent movement of the arm when it is first powered on and servos are energized.


  'Once the initial positions have been initialized start the servos object in a new cog.
  startOK := servos.start(@pin[0], @CurrPos[0], @NewPos[0], @NumPulses[0],@GradMove,@AccDecMove,@HoldPulse, NumServos)            

  'The bits used to set the type of movement and holding pulse option can be set individually for each servo
  'however for this example all servo bits are set in the same way.
  GradMove~ 'No Gradual Movement
  AccDecMove~~  'Use Accelerated/Decelerated moves
  HoldPulse~~   'Send holding pulses

  'The following lines use the sample M6 procedure to move the arm in a pre-defined sequence of movements.
  M6(70,0,-540,-410,0,0,100,4) 'Move arm to storage position and hold it for 4 seconds.
  M6(70,0,0,0,0,0,100,0)       'All values = 0, with a trim of 70 in base to make the arm point exactly forward
  M6(70,300,0,0,0,0,150,0)     'Move Shoulder towards back

  M6(70,300,0,0,0,-500,80,0)   'Open Gripper
  M6(70,300,0,0,0,300,80,0)    'Close Gripper

'Rotate wrist using procedure M6
  M6(70,300,0,0,900,0,80,0)    'Rotate Wrist
  M6(70,300,0,0,-900,0,80,1)   'Rotate Wrist

'Rotate wrist using sample procedure M1, use Gradual Movement. Complete each movement in one second (50 pulses)
  M1(5,900,50,1,0,1,1)    'Rotate Wrist
  M1(5,-900,50,1,0,1,3)   'Rotate Wrist and then wait 3 seconds

'Rotate wrist using sample procedure M1, use Accelerated/Decelerated Movement. Complete each movement in one second (50 pulses)
  M1(5,900,50,0,1,1,1)    'Rotate Wrist
  M1(5,-900,50,0,1,1,3)   'Rotate Wrist and then wait 3 seconds

'Rotate wrist using sample procedure M1, use Immediate (fastest) Movement. Send pulses for one second (50 pulses)
  M1(5,900,50,0,0,0,1)    'Rotate Wrist
  M1(5,-900,50,0,0,0,3)   'Rotate Wrist and then wait 3 seconds  

  AccDecMove~~  'Use Accelerated/Decelerated moves  

  M6(70,300,0,900,0,0,80,0)    'Hand up
  M6(70,300,0,-900,0,0,80,0)   'Hand down

  M6(70,300,300,0,0,0,50,0)    'Move Elbow towards back 

  M6(-770,300,300,0,0,0,50,0)  'Move Base 90 to degrees left
  M6(970,300,300,0,0,0,120,0)  'Move Base 90 to degrees right
  M6(70,-720,800,0,0,0,160,4)  'Arm straight ahead
    
  M6(70,0,800,0,0,0,70,2)      'Arm straight up

'Get Lego Piece
  M6(970, 320,-350,-650,0,-500,60,0)  'Move Base 90 to right
  M6(970, 50,-460,-447,0,-500,60,0)   'Lower hand
  M6(970, 50,-460,-447,0, 50,40,0)    'Grab lego piece
  M6(970, 320,-350,-650,0,50,60,0)    'Raise Hand

  M6(970,-720,800,0,0,50,100,2)       'Straight Ahead Right Corner
  M6(-770,0,800,0,0,50,180,2)         'Straight up Left Corner

  M6(-500,-500,300,900,900,50,90,0)   'Combined moves
  M6(500,500,-300,-900,-900,50,90,0)        

'Drop Lego Piece
  M6(970, 320,-350,-650,0,100,60,0)   'Move Base 90 to right
  M6(970, 50,-460,-447,0,50,60,1)     'Lower hand
  M6(970, 50,-460,-447,0, -500,40,0)  'Drop lego piece
  M6(970, 320,-350,-650,0,-500,60,0)  'Raise Hand    

'Store Position
  M6(70,0,0,0,0,0,200,0)       'All values = 0, with a trim of 70 in base to make the arm point exactly forward
  M6(70,0,-540,-410,0,0,200,1) 'Move arm to storage position.


  servos.stop            'Stop the servos object.

PRI M1(SER,POS,PULSES,GR,AD,HP,WAIT) 'Example of procedure to set all parameters of one servo and move it.
  if GR
        GradMove := GradMove | |<(SER-1)
  else
        GradMove := GradMove & !|<(SER-1)
  if AD
        AccDecMove := AccDecMove | |<(SER-1)
  else
        AccDecMove := AccDecMove & !|<(SER-1)
  if HP
        HoldPulse := HoldPulse | |<(SER-1)
  else
        HoldPulse := HoldPulse & !|<(SER-1) 
  NewPos[SER-1] :=  POS
  NumPulses[SER-1]:= PULSES     'Executes movement
  repeat while NumPulses[SER-1] 'Wait for movement to complete 
  if WAIT <> 0                  'Wait additional seconds (optional)
        waitcnt(clkfreq * WAIT + cnt)

PRI M6(POS1,POS2,POS3,POS4,POS5,POS6,PULSES, WAIT) | index  'Example of procedure to set new positions for 6 servos and move all of them at the same time.
  NewPos[0] :=  POS1
  NewPos[1] :=  POS2
  NewPos[2] :=  POS3
  NewPos[3] :=  POS4
  NewPos[4] :=  POS5
  NewPos[5] :=  POS6
  repeat index from 0 to NumServos-1 
        NumPulses[index]:= PULSES
  repeat while NumPulses[0] | NumPulses[1] | NumPulses[2] |  NumPulses[3]|  NumPulses[4] | NumPulses[5]   'Wait for movements to complete 
  if WAIT <> 0
        waitcnt(clkfreq * WAIT + cnt)

PRI S6(POS1,POS2,POS3,POS4,POS5,POS6)  'Example of procedure to initialize the positions of 6 servos.
  NewPos[0] := CurrPos[0]:= POS1
  NewPos[1] := CurrPos[1]:= POS2
  NewPos[2] := CurrPos[2]:= POS3
  NewPos[3] := CurrPos[3]:= POS4
  NewPos[4] := CurrPos[4]:= POS5
  NewPos[5] := CurrPos[5]:= POS6

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}              