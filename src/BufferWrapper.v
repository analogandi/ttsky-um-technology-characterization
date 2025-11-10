`timescale 1ns/1ps
module buf_hd_1_wrapper (
    input  wire A,
    output wire Y
);

`ifdef SIMULATION
    assign #0.045 Y = A;
`else
    sky130_fd_sc_hd__buf_1 u_buf (
        .A(A),
        .X(Y)
    );
`endif

endmodule

