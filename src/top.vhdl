library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tt_um_example is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_example;

architecture RTL of tt_um_example is

    -- length of inverter chain (you can rename or adjust)
    constant g_chainDepth : natural := 100;

    -- inverter chain signals
    signal chain : std_logic_vector(g_chainDepth downto 0);

    -- synthesis attribute: prevent optimization
    attribute keep : string;
    attribute keep of chain : signal is "yes";

begin

    ---------------------------------------------------------------------
    -- Assign chain input from ui_in(0)
    ---------------------------------------------------------------------
    chain(0) <= ui_in(0);

    ---------------------------------------------------------------------
    -- Generate the SKY130 inverter chain
    ---------------------------------------------------------------------
    GEN_INV : for i in 0 to g_chainDepth-1 generate
        INV_HARD : entity sky130_fd_sc_hd__inv_1
            port map (
                A => chain(i),
                Y => chain(i+1)
            );
    end generate GEN_INV;

    ---------------------------------------------------------------------
    -- Chain output drives uo_out(0)
    ---------------------------------------------------------------------
    uo_out(0) <= chain(g_chainDepth);

    ---------------------------------------------------------------------
    -- All unused outputs forced low / safe
    ---------------------------------------------------------------------
    uo_out(7 downto 1) <= (others => '0');
    uio_out            <= (others => '0');
    uio_oe             <= (others => '0');

end RTL;

