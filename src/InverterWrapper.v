`timescale 1ns/1ps
module inv_hd_1_wrapper (
    input  wire A,
    output wire Y
);

`ifdef SIMULATION
    assign #0.025 Y = ~A;

`else
    sky130_fd_sc_hd__inv_1 u_inv (
        .A(A),
        .Y(Y)
    );
`endif

endmodule
