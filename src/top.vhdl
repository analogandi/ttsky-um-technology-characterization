library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tt_um_example is
    generic (MAX_COUNT : natural := 10_000_000);
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

    constant g_chainDepth : natural := 100;

    signal chain : std_logic_vector(g_chainDepth downto 0);

    attribute keep : string;
    attribute keep of chain : signal is "yes";

begin

    chain(0) <= ui_in(0);

    GEN_INV : for i in 0 to g_chainDepth-1 generate
        INV_WRP : entity work.inv_hd_1_wrapper
            port map (
                A => chain(i),
                Y => chain(i+1)
            );
    end generate;

    uo_out(0) <= chain(g_chainDepth);
    uo_out(7 downto 1) <= (others => '0');
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');

end RTL;
