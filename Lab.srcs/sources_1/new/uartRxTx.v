`timescale 1ns / 1ps

module uartRxTx
(
    input wire clock,
    
    input wire rxIn,
    input wire[63:0] registerData,
    
    input isSorted,
    
    output wire txOut,
    
    output wire [7:0] Output_Wire_UART_ReaderASCIIPackage_8bits,
    output wire Output_Wire_UART_ReaderPackageReady_State,
    output wire[4:0] Output_Wire_UART_AscToHex_Hex_5bits
);

    assign Output_Wire_UART_ReaderASCIIPackage_8bits = Wire_UART_ReaderASCIIPackage_8bits;
    assign Output_Wire_UART_ReaderPackageReady_State = Wire_UART_ReaderPackageReady_State;
    assign Output_Wire_UART_AscToHex_Hex_5bits = Wire_UART_AscToHex_Hex_5bits;
    
////////////////////////UART_ASCII_To_Hex///////////////////////
    wire [4:0] Wire_UART_AscToHex_Hex_5bits;

    UART_ASCII_To_Hex module_UART_ASCII_To_Hex(
        .Input_clk( clock ),
        .Input_Clear_clk( 1'b0 ),
        .Input_UART_ReaderReady_State( Wire_UART_ReaderPackageReady_State ),
        .Input_ASCII_8bits( Wire_UART_ReaderASCIIPackage_8bits ),
        .Output_Hex_5bits( Wire_UART_AscToHex_Hex_5bits ));
////////////////////////UART_ASCII_To_Hex///////////////////////

////////////////////////UART_Reader///////////////////////
    wire [7:0] Wire_UART_ReaderASCIIPackage_8bits;
    wire Wire_UART_ReaderPackageReady_State;
    wire Wire_UART_ReaderError_State;

    // Module to read from Computer by UART packages
    UART_Reader module_UART_Reader(
        .Input_clk( clock ),
        .Input_Clear_clk( 1'd0 ),
        .Input_RX( rxIn ),
        .Input_ReadNextPackage( 1'd1 ),
        .Output_ASCII_Package_8bits( Wire_UART_ReaderASCIIPackage_8bits ),
        .Output_PackageReady( Wire_UART_ReaderPackageReady_State ),
        .Output_Error( Wire_UART_ReaderError_State ));
////////////////////////UART_Reader///////////////////////

////////////////////////UART_Hex_To_ASCII///////////////////////
    wire [7:0] Wire_UART_HexToAsc_Package_8bits;

    UART_Hex_To_ASCII module_UART_Hex_To_ASCII(
        .Input_clk( clock ),
        .Input_Hex_5bits( Wire_BacDatTrans_HexPart_5bits ),
        .Output_ASCII_8bits( Wire_UART_HexToAsc_Package_8bits ));
////////////////////////UART_Hex_To_ASCII///////////////////////

////////////////////////UART_BackpackData_Transiver_Helper///////////
    wire Wire_UART_BacDatTrans_Transfer_State;    
    wire [4:0] Wire_BacDatTrans_HexPart_5bits;
        
    UART_BackpackData_Transiver_Helper module_UART_BackpackData_Transiver_Helper(
        .Input_clk( clock ),
        .Input_Queue_Full( Wire_UART_Transiver_QueueFull ),
        .Input_SortData_64bits( registerData ),
        .Input_Transfer( isSorted == 1'd1 ),
        .Output_HexNumber( Wire_BacDatTrans_HexPart_5bits ),
        .Output_Transfer( Wire_UART_BacDatTrans_Transfer_State ));    
////////////////////////UART_BackpackData_Transiver_Helper/////////

////////////////////////UART Transiver///////////////////////
    wire Wire_UART_Transiver_QueueFull;
    
    UART_Transiver module_UART_Transiver(
        .Input_clk( clock ),
        .Input_Clear_clk( 1'd0 ),
        .Input_Package_Data( Wire_UART_HexToAsc_Package_8bits ),
        .Input_Transfer( Wire_UART_BacDatTrans_Transfer_State == 1'd1),
        .Output_Queue_Full( Wire_UART_Transiver_QueueFull ),
        .Output_UART_Tx( txOut ));
////////////////////////UART Transiver/////////////////////

endmodule
