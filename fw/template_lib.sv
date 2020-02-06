/****************************************************************************
 Project:  
 File:   snesMasterPack - Lib
 Author: Steven Seppala

 Description:           
   Library SNESHDL - package SPC - System Verilog Version

    Contains : Common directives, functions, and data types for compilation with the 
                SNESHDL and its functionality. 



 Notes:
    All SIGNALs ending with neg are active low.
    All signalNamesInTheDesign are camelCase
    All Inputs end with In
    All Outputs end with Out
    All Registers end with Reg

    All CONSTANTS are CAPITAL LETTERS
    All GENERICS are CAPITAL LETTERS 

 Revision History:
  06FEB2020: Steven Seppala
    Comments: Inital release

****************************************************************************/

package top_lib;

  `define COLLECTED_GIT_HASH;
  `define MAJOR_VER;
  `define MINOR_VER;
  parameter integer MAJ_VER = MAJOR_VER; 
  parameter integer MIN_VER = MINOR_VER;
  parameter integer GIT_HSH = COLLECTED_GIT_HASH;

  parameter int STANDARAD_REGISTER_SIZE = 32;

  typedef reg [STANDARAD_REGISTER_SIZE -1 : 0] sreg;
  typedef reg [(STANDARAD_REGISTER_SIZE*2) -1 : 0] dreg;

  struct {
    sreg majVer;
    sreg minVer;
    sreg gitHash;
  } infoRegs;

endpackage : top_lib
