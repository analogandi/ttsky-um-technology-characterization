library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;

entity tt_um_example is
    port (
        ui_in   : in  std_ulogic_vector(7 downto 0);
        uo_out  : out std_ulogic_vector(7 downto 0);
        uio_in  : in  std_ulogic_vector(7 downto 0);
        uio_out : out std_ulogic_vector(7 downto 0);
        uio_oe  : out std_ulogic_vector(7 downto 0);
        ena     : in  std_ulogic;
        clk     : in  std_ulogic;
        rst_n   : in  std_ulogic
    );
end tt_um_example;

architecture RTL of tt_um_example is
    -- wires to alias/rename the top port signals
    signal clk_50Mhz_in : std_ulogic;
    signal enable_in    : std_ulogic;
    signal reset_n_in   : std_ulogic;

    signal htol_in  : std_ulogic;
    signal chain_in : std_ulogic;
    signal pad_in   : std_ulogic;
    signal mode_in  : std_ulogic_vector(3 downto 0);

    signal htol_out         : std_ulogic;
    signal chain_out        : std_ulogic;
    signal pad_50mhz_out    : std_ulogic;
    signal pad_1mhz_out     : std_ulogic;
    signal pad_high         : std_ulogic;
    signal pad_low          : std_ulogic;

    signal htol_latched     : std_ulogic := '0';

    signal htol_1s_toggle       : std_ulogic;
    signal htol_1Mhz_toggle     : std_ulogic;
    signal htol_50Mhz_toggle    : std_ulogic;

    signal pads_char : std_ulogic_vector(3 downto 0);
    signal pads_htol : std_ulogic_vector(3 downto 0);

    signal inverter_chain_in    : std_ulogic;
    signal inverter_chain_out1  : std_ulogic;
    signal inverter_chain_out2  : std_ulogic;
    signal inverter_chain_out3  : std_ulogic;

begin
    -- alias/rename the top port signals
    clk_50Mhz_in    <= clk;
    enable_in       <= ena;
    reset_n_in      <= rst_n;
    htol_in         <= uio_in(0);
    mode_in         <= uio_in(4 downto 1);
    chain_in        <= uio_in(6);
    pad_in          <= uio_in(7);

    inverter_chain_in   <= chain_in;
    chain_out <= inverter_chain_out3;

    uio_out            <= (others => '0');
    uio_oe             <= (others => '0');

    clkgen_inst: entity work.ClockGen(RTL)
    port map (
        clk_50Mhz_in      => clk_50Mhz_in,
        reset_n_in        => reset_n_in,
        enable_in         => enable_in,
        htol_1s_toggle    => htol_1s_toggle,
        htol_1Mhz_toggle  => htol_1Mhz_toggle,
        htol_50Mhz_toggle => htol_50Mhz_toggle
    );

    inverterchain_inst: entity work.InverterChain(RTL)
    port map (
        chain_in    => inverter_chain_in,
        chain_mid   => inverter_chain_out1,
        chain_3q    => inverter_chain_out2,
        chain_out   => inverter_chain_out3
    );



    process(clk_50Mhz_in, reset_n_in)
    begin
        if reset_n_in = '0' then
            htol_latched <= '0';
        elsif rising_edge(clk_50Mhz_in) then
            if enable_in = '1' then
                htol_latched <= htol_in;
            end if;
        end if;
    end process;

    -- Mux control for HTOL led indicator
    htol_out <= '1' when htol_latched = '0' else htol_1s_toggle;

    -- Mux control for pads
    pads_htol <= (htol_50Mhz_toggle & htol_1Mhz_toggle & '1' & '0');
    pads_char <=    ("1111") when mode_in = x"0" else
                    ("0000") when mode_in = x"1" else
                    (pad_in & pad_in & pad_in & pad_in) when mode_in = x"2" 
                    else ("0000");

    uo_out(7 downto 4) <=   pads_char when (enable_in = '1' and htol_latched = '0') else
                            pads_htol when (enable_in = '1' and htol_latched /= '0') else
                            (others => '0');


end architecture RTL;

